require 'test_helper'
require "#{Rails.root}/test/modules/raw_bibtex_asserts"


class BibfileTest < ActiveSupport::TestCase
	include RawBibtexAsserts

	def setup
    @library = libraries(:default)
    @bibtex_file = bibfiles(:parent_set)
    @parent = raw_bibtex_entries(:set_crossref_parent)
    @good_child = raw_bibtex_entries(:set_crossref_good_child)
    @weird_child = raw_bibtex_entries(:set_crossref_weird_child)
    @bad_child = raw_bibtex_entries(:set_crossref_bad_child)
    @ok_child = raw_bibtex_entries(:set_crossref_ok_child)
    @bibtex_file.raw_bibtex_entries.each {|entry|
    	entry.reset
    	entry.save
    }
 	end

 	  # called after every single test
  def teardown
  end


  test "set_parent_records" do
  	@bibtex_file.set_parent_records
  	@weird_child.reload
  	@ok_child.reload
  	@bad_child.reload
  	@good_child.reload
  	assert_equal(@parent, @good_child.parent_record, "Set parent_record correctly")
  	assert_equal(@parent, @weird_child.parent_record, "Set parent_record correctly")
  	assert_equal(@parent, @ok_child.parent_record, "Set parent_record correctly")
  	assert_equal(nil, @bad_child.parent_record, "Parent record remains unset")
  end

end
