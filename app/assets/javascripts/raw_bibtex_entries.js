function InitRawBibtexList(container) {
	container.find('.header-row').off("click");
	container.find('.header-row').click(function (e) {
			$(this).find('.caret-element').toggleClass("caret caret-right");
			$(this).parent().find('.raw-bibtex-content').toggle();
		});
}