class LabelsController < ApplicationController

	before_action :set_library, only:  [:create]
	before_action :check_create_authorization, only:  [:create]


	def create
		@parent = Label.where(id: params[:parent_id], library: @library).take
		@label = Label.new(label_params)
		@label.library = @library
		if @label.save
			@parent.children << @label if @parent
			respond_to do |format|
	      format.js { render 'refresh', notice: 'Label Created'}
	    end
	  else
	  	respond_to do |format|
	  		format.json { render json: @label.errors, notice: 'Error Creating Label' }
	  	end
	 	end
	end

	private

  def check_create_authorization
    raise NotAuthorized unless @library.can_edit?(current_user)
  end

	def label_params
	  params.permit(:name)
	end

  def set_library
    @library = Library.find(params[:library_id])
    raise NotAuthorized unless @library
  end

end
