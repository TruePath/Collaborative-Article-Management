require 'test_helper'

class RawBibtexEntryTest < ActiveSupport::TestCase

  # called before every single test
  def setup
    @library = libraries(:default)
    @basic = raw_bibtex_entries(:basic)
    @basic.reset
    @unbalanced_interior_one = raw_bibtex_entries(:unbalanced_interior_one)
    @unbalanced_interior_two = raw_bibtex_entries(:unbalanced_interior_two)
    @missing_commas = raw_bibtex_entries(:missing_commas)
    @unclosed_field = raw_bibtex_entries(:unclosed_field)
    @junk = raw_bibtex_entries(:junk)
    @unterminated = raw_bibtex_entries(:unterminated)
    @no_comma_after_key = raw_bibtex_entries(:no_comma_after_key)
    @trailing_spaces = raw_bibtex_entries(:trailing_spaces)
    @nokey_with_comma = raw_bibtex_entries(:nokey_with_comma)
    @nokey_no_comma = raw_bibtex_entries(:nokey_no_comma)
    @crossref = raw_bibtex_entries(:crossref)
    @nokey_no_comma.reset
    @nokey_with_comma.reset
    @trailing_spaces.reset
    @no_comma_after_key.reset
    @unbalanced_interior_one.reset
    @unbalanced_interior_two.reset
    @missing_commas.reset
    @unclosed_field.reset
    @junk.reset
    @unterminated.reset
  end

  # called after every single test
  def teardown
  end

  def assert_num_errors(raw, num, msg = "")
  	assert_equal(num, raw.num_errors, "Has #{num} errors" + (msg.empty? ? "" : " : " + msg))
  	assert_equal(num, raw.messages.num_errors, "Has #{num} error messages" + (msg.empty? ? "" : " : " + msg))
  end

  def assert_num_warnings(raw, num, msg = "")
  	assert_equal(num, raw.num_warnings, "Has #{num} warnings" + (msg.empty? ? "" : " : " + msg))
  	assert_equal(num, raw.messages.num_warnings, "Has #{num} warning messages" + (msg.empty? ? "" : " : " + msg))
  end

  def assert_num_msgs(raw, nume=0, numw=0, msg = "")
  	assert_num_errors(raw, nume, msg)
  	assert_num_warnings(raw, numw, msg)
  end

  def assert_has_msg(raw, text, line = nil, char = nil, type = nil)
  	assert(raw.messages.count {|msg| val = (msg.text == text)
  	val &&= msg.line == line if line
  	val &&= msg.char == char if char
  	val &&= msg.is_a? type if type
  	val
  	 }, "Has appropriate message")
  end

  test "reset" do
  	assert_num_msgs(@basic, 0, 0, "Num errors & warnings init to 0")
  	assert_instance_of(Messages, @basic.messages, "Serialized messages is a Messages obj")
  	assert_instance_of(Hash, @basic.fields, "Serialized fields is a Hash obj")
  	assert_equal(Hash.new, @basic.fields, "Fields is blank hash")
  end

  test "parse key" do
  	@basic.extract_key
  	assert_equal("ScalingDatabaseLanguagestoHigher-OrderDistributedProgramming", @basic.key,  "Extract good key")
    assert_equal("inproceedings", @basic.bibtex_type)
 		assert_num_msgs(@basic)
  	@no_comma_after_key.extract_key
  	assert_equal(@no_comma_after_key.key, "ScalingDatabaseLanguagestoHigher-OrderDistributedProgramming", "Extract key no comma")
    assert_equal("inproceedings", @no_comma_after_key.bibtex_type)
  	assert_num_msgs(@no_comma_after_key, 0, 1)
  	@trailing_spaces.extract_key
  	assert_equal(@trailing_spaces.key, "ScalingDatabaseLanguagestoHigher-OrderDistributedProgramming", "Extract key with trailing spaces")
  	assert_equal("inproceedings", @trailing_spaces.bibtex_type)
    assert_num_msgs(@trailing_spaces)
  	@nokey_with_comma.extract_key
  	assert_equal(@nokey_with_comma.key, "", "Extract key with trailing spaces")
    assert_equal("inproceedings", @nokey_with_comma.bibtex_type)
  	assert_num_msgs(@nokey_with_comma, 1, 0)
  	assert_has_msg(@nokey_with_comma, "Missing Key", 0)
  	@nokey_no_comma.extract_key
  	assert_equal(@nokey_no_comma.key, "", "Extract key with trailing spaces")
    assert_equal("inproceedings", @nokey_no_comma.bibtex_type)
  	assert_num_msgs(@nokey_no_comma, 1, 0)
  	assert_has_msg(@nokey_no_comma, "Missing Key", 0)
  end

  test "parse interior" do
  	interior = <<END_STRING
abstract = {We describe the Tycoon approach to scale the successful notion of a uniform, type-safe persistent object store to communication-intensive applications and applications where long-term activities are allowed to span multiple autonomous network sites. Exploiting stream-based data, code and thread exchange primitives we present several distributed programming idioms in Tycoon. These programming patterns range from client-server communication based on polymorphic higher-order remote procedure calls to migrating autonomous agents that are bound dynamically to network resources present at individual network nodes. Following Tycoon's add-on approach, these idioms are not cast into built-in syntactic forms, but are expressed by characteristic programming patterns exploiting communication primitives encapsulated by library functions. Moreover, we present a novel form of binding support for ubiquitous resources which drastically reduces communication traffic for modular distributed applications. },
author = {Mathiske, B and Matthes, F and Schmidt, J W},
booktitle = {In Proceedings of the Fifth International Workshop on Database Programming Languages},
file = {:Users/TruePath/Google Drive/Managed Papers/Mendeley/Scaling Database Languages to Higher-Order Distributed Programming - Mathiske, Matthes, Schmidt - 1995.pdf:pdf},
keywords = {RPC;Remote Procedure Call;Remote Execution},
publisher = {Springer-Verlag},
title = {{Scaling Database Languages to Higher-Order Distributed Programming}},
year = {1995}
}
END_STRING

		assert_equal(interior.strip, @basic.process_wrapper, "Check parsed interior correctly for valid entry")
  end


  test "parse_files" do
    single_file = ":Users/TruePath/Library/Application Support/Mendeley Desktop/Downloaded/Bobba et al. - Unknown - PERFORMANCE PATHOLOGIES IN HARDWARE TRANSACTIONAL MEMORY(2).pdf:pdf"
    double_file = ":Users/TruePath/Google Drive/Managed Papers/Mendeley/Variable-Arity Polymorphism - Strickland, Tobin-Hochstadt, Felleisen - 2008.bib:bib;:Users/TruePath/Google Drive/Managed Papers/Mendeley//Practical variable-arity polymorphism - Strickland, Tobin-Hochstadt, Felleisen - 2009.pdf:pdf"
    @basic.parse_files(single_file, 0)
    assert_equal(1, @basic.filenames.length)
    assert_equal("Users/TruePath/Library/Application Support/Mendeley Desktop/Downloaded/Bobba et al. - Unknown - PERFORMANCE PATHOLOGIES IN HARDWARE TRANSACTIONAL MEMORY(2).pdf", @basic.filenames[0])
    @junk.parse_files(double_file, 0)
    assert_equal(2, @junk.filenames.length)
    assert_equal("Users/TruePath/Google Drive/Managed Papers/Mendeley//Practical variable-arity polymorphism - Strickland, Tobin-Hochstadt, Felleisen - 2009.pdf", @junk.filenames[1])
    assert_equal("Users/TruePath/Google Drive/Managed Papers/Mendeley/Variable-Arity Polymorphism - Strickland, Tobin-Hochstadt, Felleisen - 2008.bib", @junk.filenames[0])
  end

  test "parse_urls" do
    single_url = "http://slashdot.org "
    double_url = "http://slashdot.org http://arstechnica.com"
    @basic.parse_urls(single_url, 0)
    assert_equal(1, @basic.links.length)
    assert_equal("http://slashdot.org", @basic.links[0])
    @junk.parse_urls(double_url, 0)
    assert_equal(2, @junk.links.length)
    assert_equal("http://arstechnica.com", @junk.links[1])
    assert_equal("http://slashdot.org", @junk.links[0])
  end

  test "parse_authors" do
    @basic.parse_authors("Mathiske, B and Matthes, F and Schmidt, J W", 0)
    assert_equal(3, @basic.authors.length)
    assert_equal("Mathiske, B", @basic.authors[0])
    assert_equal("Matthes, F", @basic.authors[1])
    assert_equal("Schmidt, J W", @basic.authors[2])
    @basic.reset
    @basic.parse_authors("Mathiske, B; Matthes, F; Schmidt, J W", 0)
    assert_equal(3, @basic.authors.length)
    assert_equal("Mathiske, B", @basic.authors[0])
    assert_equal("Matthes, F", @basic.authors[1])
    assert_equal("Schmidt, J W", @basic.authors[2])
  end

  test "parse_fields" do
    @crossref.parse
    assert_equal(5, @crossref.fields.length)
    assert_equal("We describe the Tycoon approach to scale the successful notion of a uniform, type-safe persistent object store to communication-intensive applications and applications where long-term activities are allowed to span multiple autonomous network sites. Exploiting stream-based data, code and thread exchange primitives we present several distributed programming idioms in Tycoon. These programming patterns range from client-server communication based on polymorphic higher-order remote procedure calls to migrating autonomous agents that are bound dynamically to network resources present at individual network nodes. Following Tycoon's add-on approach, these idioms are not cast into built-in syntactic forms, but are expressed by characteristic programming patterns exploiting communication primitives encapsulated by library functions. Moreover, we present a novel form of binding support for ubiquitous resources which drastically reduces communication traffic for modular distributed applications.",
                  @crossref.fields["abstract"])
    assert_equal(3, @crossref.authors.length)
    assert_equal("Mathiske, B", @crossref.authors[0])
    assert_equal("Matthes, F", @crossref.authors[1])
    assert_equal("Schmidt, J W", @crossref.authors[2])
    assert_equal("In Proceedings of the Fifth International Workshop on Database Programming Languages",
                  @crossref.fields["booktitle"])
    assert_equal(1, @crossref.filenames.length)
    assert_equal("Users/TruePath/Google Drive/Managed Papers/Mendeley/Scaling Database Languages to Higher-Order Distributed Programming - Mathiske, Matthes, Schmidt - 1995.pdf", @crossref.filenames[0])
    assert_equal(@crossref.keyword_list.length, 3)
    assert(@crossref.keyword_list.find("RPC"))
    assert(@crossref.keyword_list.find("Remote Procedure Call"))
    assert(@crossref.keyword_list.find("Remote Execution"))
    assert_equal("Springer-Verlag", @crossref.fields["publisher"])
    assert_equal("Scaling Database Languages to Higher-Order Distributed Programming", @crossref.fields["title"])
    assert_equal("1995", @crossref.fields["year"])
    assert_equal("ScalingDatabaseLanguagestoHigher-OrderDistributedProgramming", @crossref.crossrefkey)

  end

end
