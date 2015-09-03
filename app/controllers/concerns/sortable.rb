module Sortable
  extend ActiveSupport::Concern

  included do
  	helper_method :sort_by, :sort_direction, :preserve_params
  end

  def sort_by
    controller_path.classify.constantize.column_names.include?(params[:sort_by]) ? params[:sort_by] : ""
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

  def sort(assoc)
  	if sort_by.empty?
  		return assoc
  	else
  		return assoc.order(sort_by + " " + sort_direction)
  	end
  end

  def preserve_params
  	return params.slice(:sort_by, :sort_direction)
  end



end