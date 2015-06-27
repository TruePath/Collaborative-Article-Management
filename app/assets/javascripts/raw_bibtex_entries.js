function InitRawBibtexList(container) {
	container.find('.header-row').off("click");
	container.find('.header-row').click(function (e) {
			$(this).find('.caret-element').toggleClass("caret caret-right");
			$(this).parent().find('.raw-bibtex-content').toggle();
		});
}

var bibtex_search_template = "<div class='search-notification'>" +
"<% switch(scope) {  " +
"case 'has_errors': %>" +
"<%= (arg ? 'Has' : 'No' )  %> Errors" +
"<% break; " +
"case 'has_warnings': %>" +
"<%= (arg ? 'Has' : 'No' ) %> Warnings" +
"<% break; " +
"case 'converted': %>" +
"<%= (arg ? 'Is' : 'Is Not' )  %> Converted" +
"<% break; " +
"case 'content': %>" +
"Content Contains <%= arg %>" +
"<% break; } %>" +
'<button type="button" class="search-cancel"><span aria-hidden="true">&times;</span></button>' +
"</div>";