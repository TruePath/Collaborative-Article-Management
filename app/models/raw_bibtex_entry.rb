require 'forwardable'
require "set"
require 'digest/sha2'

class Message
	include Comparable

	attr_accessor :line, :char, :type, :text
	alias :line_number :line
  alias :char_number :line

	def initialize(text, line_num, char_num)
    @char = char_num
		@line = line_num
		@text = text
	end

	def <=>(anOther)
    if self.line == anOther.line
      self.char <=> anOther.char
    else
		  self.line <=> anOther.line
    end
	end

  def is_error?
    self.is_a? ErrorMessage
  end

  def is_warning?
    self.is_a? WarningMessage
  end

end

class ErrorMessage < Message
  def initialize(text, line_num, char_num)
    super(text, line_num, char_num)
  end

end

class WarningMessage < Message
  def initialize(text, line_num, char_num)
    super(text, line_num, char_num)
  end
end

class Messages
	include Enumerable
	extend Forwardable

  attr_accessor :num_errors, :num_warnings

	def initialize(line_breaks) #line_breaks are the charachter positions the lines end at
    @line_breaks=line_breaks.to_a
		@msg_set = SortedSet.new()
    @num_errors = 0
    @num_warnings = 0
	end

  def add_error(text, char_position)
    @num_errors += 1
    line, offset = line_and_offset(char_position)
    @msg_set.add(ErrorMessage.new(text, line, offset))
  end

  def add_warning(text, char_position)
    @num_warnings += 1
    line, offset = line_and_offset(char_position)
    @msg_set.add(WarningMessage.new(text, line, offset))
  end

  def line_and_offset(char_pos)
    return -1, -1 if char_pos == 0
    line = @line_breaks.find_index {|line_start| line_start >= char_pos }
    offset = line == 0 ? char_pos : char_pos - @line_breaks[line - 1 ]
    return line, offset
  end

  def num_errors(re = //)
    self.count {|msg|  msg.is_a?(ErrorMessage) && msg.text.match(re)}
  end

  def num_warnings(re = //)
    self.count {|msg|  msg.is_a?(WarningMessage) && msg.text.match(re)}
  end

  def errors
    self.select {|msg|  msg.is_a?(ErrorMessage) }
  end

  def warnings
    self.select {|msg|  msg.is_a?(WarningMessage) }
  end

	def_delegators :@msg_set, :<<, :each, :add, :to_a, :[], :empty?, :size, :length, :add, :add?

end

class LogToMessages

  def initialize(msgs)
    super
    @msgs=msgs
  end

  def warn(text)
    @msgs.add_warning(clean(text), position(text))
  end

  def error(text)
    @msgs.add_error(clean(text), position(text))
  end

  def debug(text)
  end

  def warn(text)
  end

  def position(error_string)
    /(?<=at[ ])(?<=position[ ])?\d*/i =~ error_string
    $&.to_i
  end

  def clean(error_string)
    error_string.sub(/at[ ](position[ ])?\d*[;]?/i)
  end


end


class RawBibtexEntry < ActiveRecord::Base
  include Filterable
	#num_errors, num_warnings, messages:text, content: text, crossref_failure:boolean, crossrefkey:string, key:string, converted:boolean
  before_update :set_digest
  scope :has_errors, -> (pos) { if pos.present?
                                  where( "num_errors " + (pos.to_bool ? ">" : "=") + "0")
                                end }
  scope :has_warnings, -> (pos) { if pos.present?
                                    where( "num_warnings " + (pos.to_bool ? ">" : "=") + "0")
                                  end }
  scope :converted, -> (conv) {where converted: conv.to_bool if conv.present?}
  scope :contains, -> (str) {where("content LIKE ?", "%#{str.to_s}%") if str.present?}


  belongs_to :library
  belongs_to :reference
  belongs_to :bibfile
  belongs_to :parent_record, :polymorphic => true
  has_many :raw_children, class_name: "RawBibtexEntry", foreign_key: "parent_record_id", as: :parent_record
  serialize :messages #, Messages #format array of Message
  serialize :fields #, Hash #of field values
  paginates_per 50


  ESC= /(?<![\\])(?>[\\](?:[\\][\\])*)/
  UNESC= /(?:\A|(?<=[^\\]))(?:[\\][\\])*/
  BALANCED_BRACES = /#{UNESC}(?<match>(?<braced>[{]
                        (?>   # atomic captu
                          (?>  (?:#{ESC}[{]|#{ESC}[}]|[^{}])+     )  #atomic capture
                          |\g<braced>
                        )*
                        [}]   ) ) /xm
  INTERIOR_BALANCED_BRACES = /
                        (?>
                          (?:#{ESC}[{]|#{ESC}[}]|[^{}])++
                          |(?<braced>[{]
                              (?>   # atomic captu
                                (?>  (?:#{ESC}[{]|#{ESC}[}]|[^{}])+     )  #atomic capture
                                |\g<braced>
                              )*+
                          [}] )
                        )*+
                          /xm
  CHECK_BALANCED_BRACES = /\A(?<match>(?:#{ESC}[{]|#{ESC}[}]|[^{}])*+
                        [{](?<braced>
                        (?>   # atomic captu
                          (?>  (?:#{ESC}[{]|#{ESC}[}]|[^{}])+     )  #atomic capture
                          |[{]\g<braced>
                        )*
                        [}]   ) )*+\z /xm
  FIELD = /[\n\r \t]*(?<fieldname>[[:alpha:]]*+)[ \t]*=[ \t]*/xm
  PARSE_FIELD = /(?:(?:\A|\G)|(?<=[}][,])|(?<=[}][\n\r]))#{FIELD}[{](?<interior>#{INTERIOR_BALANCED_BRACES}|.*?)[}][\,]?(?=[ \n\r\t]*(?:[[:alpha:]]*+[ \t]*=|[}]?[\n\r\t ]*\z))/xm

  def self.split_entries(file_contents)
    return file_contents.split(/[\n\r]+  (?=[@]  [[:alpha:]]*?   [{])/xm).drop(1)
  end

  def error?
  	return self.num_errors && self.num_errors > 0
  end

  def warning?
  	return self.num_warnings && self.num_warnings > 0
  end

  def can_edit?(user)
  	return self.library.user == user
  end

  def can_view?(user)
  	return self.library.user == user
  end

  def add_error(text, pos)
    self.messages.add_error(text, pos)
    self.num_errors += 1
  end

  def add_warning(text, pos)
    self.messages.add_warning(text, pos)
    self.num_warnings += 1
  end

  def process_wrapper #We leave the final } in the interior
    head_match = /\A[\n\r\t ]*[@][[:alpha:]]+[{] # @blah{ part
      [^[:space:],{}]* #key
      [ \t]*[,\n\r][ \n]* /xm.match(self.content)
    @interior_start = head_match.end(0)
    @interior=self.content[head_match.end(0)..-0].strip
    return @interior
  end

  def parse_fields
    offset = 0
    while (match = @interior.match(PARSE_FIELD, offset) )
      key = match[1]
      content = match[2]
      if (key == "crossref")
        self.crossrefkey = content
      else
        self.fields[key] = content
      end
      if (match.begin(0) > offset + 1)
        add_error("Could not parse", @interior_start + offset  )
      end
      offset = match.end(0)
    end
    if (match = @interior.match(/[^\n\r\t ,}]/, offset) )
      add_error("Could not parse", @interior_start + match.begin(0) )
    elsif (! @interior.match(/[\n\r\t ]*[}][\n\r\t ]*\z/, offset) )
      add_warning("Entry Improperly Terminated", @interior_start + offset)
    end
  end

  def is_entry?
    return true  if /\A[\n\r\t ]*[@][[:alpha:]]+[{]/.match(self.content)
    return false
  end

  def extract_key
    match = /(?: \A[\n\r\t ]*[@][[:alpha:]]+[{][ \t]*) #End ungrouped match
        ([^[:space:]\,{}]+) #actual capture...everything without comma, whitespace or {}
       (?=[ \t]*\,[\n\r])/x.match(self.content)
    if match
      self.key = match[1]
      return true
    end
    match = /(?: \A[\n\r\t ]*[@][[:alpha:]]+[{][ \t]*) #End ungrouped match
        ([^[:space:]\,{}]+) #actual capture...everything without comma, whitespace or {}
       (?=[ \t]*[\,\n\r])/x.match(self.content)
    if match
      self.key = match[1]
      add_warning("Improperly Terminated Key", match.end(0))
      return true
    end
    start_match = /\A[\n\r ]*[@][[:alpha:]]+[{]/xm.match(self.content)
    add_error("Missing Key", start_match.end(0))
    self.key = ""
    return false
  end



  def balanced_braces?(str)
    CHECK_BALANCED_BRACES.match(str)[0]
  end


  def init_messages
    sum_chars = 0
    line_starts = self.content.lines.map {|line| sum_chars += line.size }
    self.messages = Messages.new(line_starts)
  end

  def init_fields
    self.fields = Hash.new
  end

  def reset
    set_digest
    init_fields
    init_messages
    self.num_warnings = 0
    self.num_errors = 0
  end

  def build_from_bibtex(entry)
    self.content = entry
    parse
  end


  def parse #Returns true if successful...even with substantial errors
    reset
    if (! self.is_entry?)
      add_error("No Entry", 0)
      return false
    end
    extract_key
    process_wrapper
    parse_fields
    # author_pos = self.content.index(/^[ \t]*author[ \t]*=/i)
    # BibTeX.log = LogToMessages.new(self.messages)
    # bib = BibTeX.parse entry,  :filter => :latex,  :parse_names => false, :include => [:errors]
    # if bib[0]
    #   bib_entry=bib[0]
    #   # if (bib_entry.respond_to? :key && ! bid_entry.key.empty?)
    #   #   self.key = bib_entry.key
    #   # else
    #   #   self.key = parse_key
    #   # end
    #   self.crossrefkey = bib_entry.crossreference if bib_entry.respond_to? :crossreference
    # end
    self.num_errors = msgs.num_errors
    self.num_warnings = msgs.num_warnings
    return true
  end

  def set_digest
    self.digest = Digest::SHA2.new(512).hexdigest(self.content)
  end

end
