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
    return -1, -1 if char_pos <= 0
    line = @line_breaks.find_index {|line_start| (line_start) > char_pos }
    line ||= @line_breaks.length
    line = line - 1
    offset = line == 0 ? char_pos : char_pos - @line_breaks[line - 1]
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

  def messages_for_line(line)
    self.select {|msg|  msg.line == line}
  end

	def_delegators :@msg_set, :<<, :each, :add, :to_a, :[], :empty?, :size, :length, :add?

end


class RawBibtexEntry < ActiveRecord::Base
  include Filterable
	#num_errors, num_warnings, messages:text, bibtex_type:string, content: text, crossref_failure:boolean, crossrefkey:string, key:string, converted:boolean, authorship_type:string
  before_update :set_digest
  scope :has_errors, -> (pos) { if pos.present?
                                  where( "num_errors " + (pos.to_bool ? ">" : "=") + "0")
                                end }
  scope :has_warnings, -> (pos) { if pos.present?
                                    where( "num_warnings " + (pos.to_bool ? ">" : "=") + "0")
                                  end }
  scope :converted, -> (conv) {where converted: conv.to_bool if conv.present?}
  scope :contains, -> (str) {where("content LIKE ?", "%#{str.to_s}%") if str.present?}

  acts_as_taggable_on :subjects, :keywords
  belongs_to :library
  belongs_to :reference
  belongs_to :bibfile
  belongs_to :parent_record, :polymorphic => true
  has_many :raw_children, class_name: "RawBibtexEntry", foreign_key: "parent_record_id", as: :parent_record
  has_many :author_names,  -> { order 'author_names.position' }, class_name: "AuthorName", foreign_key: "entry_id", :as => :entry, :dependent => :destroy
  serialize :fields, Hash #of field values
  serialize :filenames, Array
  serialize :links, Array
  serialize :messages #, Messages #format array of Message

  accepts_nested_attributes_for :author_names, allow_destroy: true, reject_if:  proc { |attributes| attributes['name'].blank? }



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
  PARSE_FIELD_UNBRACED = /(?:(?:\A|\G)|(?<=[}][,])|(?<=[}][\n\r]))#{FIELD}(?<interior>[^\,\n\r\}\{]*)[\,](?=[ \n\r\t]*(?:[[:alpha:]]*+[ \t]*=|[}]?[\n\r\t ]*\z))/xm
  ENTRY_HEAD = /\A[\n\r\t ]*[@][[:alpha:]]+[{] # @blah{ part
      [^[:space:]\,{}]* #key
      [ \t]*[,\n\r][ \n]* /xm


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

  def add_crossref_type_warning
    self.add_warning("Crossref has wrong bibtex type", 0)
  end

  def add_crossref_error
    self.add_error("Unable to find crossref", 0)
  end

  def update_type_from_children
    return unless (children = self.raw_children)
    type_freq = Hash.new
    self.bibtex_type = "article" unless self.bibtex_type
    type_freq[self.bibtex_type] = 0
    children.each do |child|
      if (match = child.bibtex_type.match(/^(?:in)(.*)$/))
        type_freq[match[1]] = 0 unless (type_freq.has_key?(match[1]))
        type_freq[match[1]] += 1
      end
    end
    best_type = self.bibtex_type
    count = type_freq[self.bibtex_type]
    type_freq.each_pair { |key, value|
      if (value > count)
        best_type = key
        count = value
      end
    }
    self.bibtex_type = best_type
    self.save
  end

  def fix_crossref_type_mismatch
    return unless self.parent_record
    if (self.bibtex_type.blank?)
      self.bibtex_type = "in" + self.parent_record.bibtex_type
      return
    end
    return unless (ptype = self.bibtex_type.match(/^(?:in)(.*)$/)[1] && self.parent_record.bibtex_type != ptype )
    self.parent_record.update_type_from_children
    return unless (ptype = self.bibtex_type.match(/^(?:in)(.*)$/)[1] && self.parent_record.bibtex_type != ptype )
    self.bibtex_type = "in" + self.parent_record.bibtex_type
  end

  def update_parent_from_child
    return unless self.parent_record
    self.fields.each_pair { |key, value|
      if (fieldname = key.match(/^(?:book)(.*)$/)[1] || (fieldname = key && Settings.copy_to_parent.include?(fieldname) ) )
        if ((fieldname == "author" || fieldname == "editor") && self.parent_record.author_names.empty?)
          self.parent_record.set_field_content(fieldname, value)
        else
          self.parend_record.field[fieldname] = value unless self.parent_record.field.has_key?(fieldname)
        end
      end
    }
  end

  # def create_parent_for_child
  #   RawBibtexEntry.create(library: )
  # end


  def set_parent_record
      parents = self.bibfile.raw_bibtex_entries.where(key: self.crossrefkey)
      if (match = self.bibtex_type.match(/^(?:in)(.*)$/) )
        parents = parents.where(bibtex_type: match[1])
      end
      parent = parents.take
      if (match && ! parent)
        parent = self.bibfile.raw_bibtex_entries.where(key: self.crossrefkey).take
        add_crossref_type_warning if parent
      end
      if (parent)
        self.parent_record = parent
        self.update_attribute(:crossrefkey, nil)
      else
        add_crossref_error
      end
      self.save
  end

  def process_wrapper #We leave the final } in the interior
    head_match = ENTRY_HEAD.match(self.content)
    if head_match
      @interior_start = head_match.end(0)
      @interior=self.content[head_match.end(0)..self.content.length].strip
      return @interior
    end
  end

  def parse_files(field, pos)
    field.strip.split(/(?<![\\])\;/).each {|entry|
      m = entry.match(/\A[\:]?((?:[^\:\;\n\r]|#{ESC}[\:\;])*)[\:]([[:alpha:]\-_]*)\Z/)
      if m
        self.filenames.push(m[1])
      else
        add_error("Failed to parse file", pos)
      end
    }
  end

  def parse_urls(field, pos)
    field.strip.split(/[ \t\n]/).each {|entry|
      if ! entry.empty?
        self.links.push(entry)
      else
        add_error("Failed to parse url", pos)
      end
    }
  end

  def parse_authors(field, pos)
    field.strip.split(/(?:[ ]and[ ])|\;/).each {|entry|
      self.author_names << AuthorName.new(name: entry)
    }
  end


  def set_field_content(key, content, offset = 0)
    case key
      when "crossref"
        add_warning("Duplicate field", @interior_start + offset) if self.crossrefkey
        self.crossrefkey = content
      when "file"
        parse_files(content, @interior_start + offset)
      when "url"
        parse_urls(content, @interior_start + offset)
      when "author", "editor"
        authorfield = content.gsub(/[\{\}]/, '')
        if (self.authorship_type == "editor")
          add_warning("Duplicate field", @interior_start + offset) if self.fields.has_key?('bookeditor')
          self.fields['bookeditor'] = self.author_names.to_a.join(' and ')
          self.author_names.destroy
        end
        if (self.authorship_type == "author")
          add_warning("Duplicate field", @interior_start + offset) if key == "author"
          self.fields['bookeditor'] = authorfield if key == "editor"
        end
        if (self.authorship_type != "author")
          self.authorship_type = key
          parse_authors(authorfield, @interior_start + offset)
        end
      when "keywords"
        self.keyword_list.add(content, parse: true)
      else
        add_warning("Duplicate field", @interior_start + offset) if self.fields.has_key?(key)
        self.fields[key] = content.strip.gsub(/[\{\}]/, '')
    end
  end

  def parse_fields
    offset = 0
    while (match = @interior.match(PARSE_FIELD, offset) )
      if (match.begin(0) > offset + 1)
        altmatch = @interior.match(PARSE_FIELD_UNBRACED, offset)
        match = altmatch if (altmatch && (altmatch.begin(0) <= (offset + 1)))
      end
      key = match[1]
      content = match[2]
      set_field_content(key, content, offset)
      if (match.begin(0) > offset + 1)
        add_error("Could not parse", @interior_start + offset  )
      end
      offset = match.end(0)
    end
    if (match = @interior.match(/[^\n\r\t ,}]/, offset) )
      add_error("Could not parse", @interior_start + match.begin(0) +1 )
    elsif (! @interior.match(/[\n\r\t ]*[}][\n\r\t ]*\z/, offset) )
      add_warning("Entry Improperly Terminated", @interior_start + offset)
    end
  end


  def extract_key
    unless ENTRY_HEAD.match(self.content)
      add_error("No Entry Head", 0)
      throw :entry_parse_fail
    end
    match = /(?: \A[\n\r\t ]*[@]([[:alpha:]]+)[{][ \t]*) #End ungrouped match
        ([^[:space:]\,{}]+) #actual capture...everything without comma, whitespace or {}
       (?=[ \t]*\,[\n\r])/x.match(self.content)
    if match
      self.bibtex_type = match[1]
      self.key = match[2]
      return true
    end
    match = /(?: \A[\n\r\t ]*[@]([[:alpha:]]+)[{][ \t]*) #End ungrouped match
        ([^[:space:]\,{}]+) #actual capture...everything without comma, whitespace or {}
       (?=[ \t]*[\,\n\r])/x.match(self.content)
    if match
      self.bibtex_type = match[1]
      self.key = match[2]
      add_warning("Improperly Terminated Key", match.end(0))
      return true
    end
    start_match = /\A[\n\r ]*[@]([[:alpha:]]+)[{]/xm.match(self.content)
    self.bibtex_type = start_match[1]
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
    line_starts.insert(0,0)
    self.messages = Messages.new(line_starts)
  end

  def init_fields
    self.fields = Hash.new
  end

  def reset
    set_digest
    init_fields
    init_messages
    self.filenames = Array.new
    self.links = Array.new
    self.num_warnings = 0
    self.num_errors = 0
    self.author_names.destroy
    self.authorship_type = nil
    self.keyword_list = ""

  end

  def build_from_bibtex(entry)
    self.content = entry
    parse
  end


  def parse #Returns true if successful...even with substantial errors
    reset
    catch :entry_parse_fail do
      extract_key
      process_wrapper
      parse_fields
    end
    return true
  end

  def set_digest
    self.digest = Digest::SHA2.new(512).hexdigest(self.content)
  end

end
