module ApplicationHelper

	def multiple_select_control(id = nil)
		idstring = id ? "id='#{id}'" : ""
		("<span class='select-control' #{idstring} ><span class='some-selected-links'>Select: " +
		"<a href='#' class='select-page-link'>All</a>, " +
		"<a href='#' class='select-all-link' style='display:none'>All <span class='select-total-num-items'></span> Items</a>" +
		"<a href='#' class='select-none-link'>None</a></span>" +
		"<span class='all-selected-links' style='display:none'>All <span class='select-total-num-items'></span> Selected. " +
		"<a href='#' class='select-none-link'>Clear</a></span>   <input type='hidden' class='hidden-select-all' name='select-all' value='0'></span>").html_safe
	end


	def update_results_controller(results_controller, items)
		("#{results_controller}.current_page = #{items.current_page}; \n" +
		"#{results_controller}.num_pages = #{items.num_pages}; \n" +
		"#{results_controller}.num_items = #{items.total_count}; \n" +
		"#{results_controller}.items_per_page = #{items.limit_value}; \n" +
		"#{results_controller}.refresh();").html_safe
	end
end
