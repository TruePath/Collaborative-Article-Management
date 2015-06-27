require 'forwardable'
require "set"

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
    false
  end

  def is_warning?
    false
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

	def initialize(line_breaks, author_pos) #line_breaks are the charachter positions the lines end at
    @line_breaks=line_breaks.to_a
    @author_pos = author_pos
		@msg_set = SortedSet.new()
    @num_errors = 0
    @num_warnings = 0
	end

  def add_error(text, char_position)
    @num_errors += 1
    line, offset = line_and_offset(char_position)
    ErrorMessage.new(text, line, offset)
  end

  def add_warning(text, char_position)
    @num_warnings += 1
    line, offset = line_and_offset(char_position)
    WarningMessage.new(text, line, offset)
  end

  def line_and_offset(char_pos)
    return -1, -1 if char_pos == 0
    line = @line_breaks.find_index {|line_start| line_start >= char_pos }
    offset = line == 0 ? char_pos : char_pos - @link_breaks[line - 1 ]
    return line, offset
  end

	def_delegators :@msg_set, :<<, :each, :add, :to_a, :[], :empty?, :size, :length

end

class LogToMessages

  def initialize(msgs)
    @msgs=msgs
  end

  def warn(text)
    @msgs.add_msg("Warning", clean(text), position(text))
  end

  def error(text)
    @msgs.add_msg("Error", clean(text), position(text))
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
  paginates_per 50


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

  def build_from_bibtex(entry)
    self.content = entry
    sum_chars = 0
    line_starts = entry.lines.map {|line| sum_chars += line.size }
    author_pos = entry.index(/^[ \t]*author[ \t]*=/i)
    msgs = Messages.new(line_starts, author_pos)
    BibTeX.log = LogToMessages.new(msgs)
    bib = BibTeX.parse entry,  :filter => :latex,  :parse_names => false, :include => [:errors]
    if bib[0]
      bib_entry=bib[0]
      self.key = bib_entry.key if bib_entry.respond_to? :key
      self.crossrefkey = bib_entry.crossreference if bib_entry.respond_to? :crossreference
    end
    self.num_errors = msgs.num_errors
    self.num_warnings = msgs.num_warnings
    self.messages = msgs
  end

end
