class ReferencesController < ApplicationController
  include Sortable
  before_action :authenticate_user!
  before_action :set_reference, only: [:show, :update, :destroy]
  before_action :set_library, only: [:create, :new, :index, :refresh_labels]
  before_action :set_references, only: [:delete, :add_label]
  before_action :check_list_authorization, only: [:index, :refresh_labels]
  before_action :check_view_authorization, only: [:show]
  before_action :check_edit_authorization, only: [:update, :destroy]
  before_action :check_create_authorization, only: [:create, :new]
  before_action :check_multiple_edit_authorization, only: [:delete, :add_label]
  # GET /references
  # GET /references.json
  def index
    @page = params[:page] || 0
    @references = @library.references.page @page
    respond_to :js
  end

  def refresh_labels
    respond_to :js
  end


  # GET /references/new
  def new
    @reference = Reference.new
    @editable = true
    @library_reference = [@library, @reference] #stupid hack because of shallow routes
    respond_to do |format|
      format.js {render "edit"}
      format.html {render "_form"}
    end
  end

  # GET /references/1/edit
  def show
    @library_reference = @reference
    respond_to do |format|
      format.js {render "edit"}
      # format.html {render "_form"}
    end
  end

  # POST /references
  # POST /references.json
  def create
    @reference = Reference.new(reference_params)
    @reference.library = @library

    respond_to do |format|
      if @reference.save
        format.js { render "_save" }
      else
        format.js { render "_save" }
      end
    end
  end

  # PATCH/PUT /references/1
  # PATCH/PUT /references/1.json
  def update
    @library=@reference.library
    respond_to do |format|
      if @reference.update(reference_params)
        format.js { render "_save" }
      else
        format.js { render "_save" }
      end
    end
  end

  # DELETE /references/1
  # DELETE /references/1.json
  def destroy
    @reference.destroy
    respond_to :js
  end

  def delete
    @references.destroy
    respond_to do |format|
      format.js { render 'refresh', notice: 'Entries Deleted'}
    end
  end

  def add_label
    @label = Label.find_by(id: params[:label_id, library: @library])
    if @label
      @references.each { |ref|
        ref.labels << @label
      }
      respond_to do |format|
        format.js { render 'refresh', notice: "Label: #{@label.name} applied"}
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_reference
      @reference = Reference.find(params[:id])
    end

    def set_library
      @library = Library.find(params[:library_id])
    end

    def set_references
      if  params[:select_all].present? && params[:select_all].to_bool
        @references = Reference.where(library: @library).filter(search_params)
      else
        @references = Reference.where(library: @library, id: params[:reference_ids])
      end
    end

    def check_edit_authorization
      raise NotAuthorized unless @reference.can_edit?(current_user)
      @editable = true
    end

    def check_view_authorization
      raise NotAuthorized unless @reference.can_view?(current_user)
      @editable = @reference.can_edit?(current_user)
    end

    def check_list_authorization
      raise NotAuthorized unless @library.can_view?(current_user)
    end

    def check_create_authorization
      raise NotAuthorized unless @library.can_edit?(current_user)
    end

    def check_multiple_edit_authorization
      raise NotAuthorized unless @library.can_edit?(current_user)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def reference_params
      params.require(:reference).permit(:key, :title, :bibtex_type, :year, :authors, :month, :tag_list => [], :subject_list => [], :keyword_list => [], fields_attributes: [:name, :value, :id, '_destroy'])
    end

    def preserve_params
      return super.merge(search_params)
    end

    def search_params
      return params.slice(:label, :key, :title, :type, :author, :year, :fulltext)
    end

end
