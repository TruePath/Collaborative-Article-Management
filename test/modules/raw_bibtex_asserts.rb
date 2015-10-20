module RawBibtexAsserts

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
  	 }, "Has appropriate message")
  end

  def assert_has_crossref_warning(raw)
  	assert_has_msg(raw, "Crossref has wrong bibtex type")
  end

  def assert_has_crossref_error(raw)
  	assert_has_msg(raw, "Unable to find crossref")
  end

end