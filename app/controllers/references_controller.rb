class ReferencesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reference, only: [:show, :edit, :update, :destroy]
  before_action :set_library, only: [:create, :new, :index]
  before_action :check_view_authorization, only: [:show]
  before_action :check_edit_authorization, only: [:edit, :update, :destroy]
  before_action :check_create_authorization, only: [:create, :new]
  # GET /references
  # GET /references.json
  def index
    @references = @library.references.page params[:page]
    respond_to :html, :js
  end


  # GET /references/new
  def new
    @reference = Reference.new
    @editable = true
    respond_to do |format|
      format.html {render "form"}
    end
  end

  # GET /references/1/edit
  def edit
    respond_to do |format|
      format.html {render "form"}
    end
  end

  # POST /references
  # POST /references.json
  def create
    @reference = Reference.new(reference_params)
    @reference.library = @library

    respond_to do |format|
      if @reference.save
        format.html { redirect_to @reference, notice: 'Reference was successfully created.' }
        format.json { render :show, status: :created, location: @reference }
      else
        format.html { render :new }
        format.json { render json: @reference.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /references/1
  # PATCH/PUT /references/1.json
  def update
    respond_to do |format|
      if @reference.update(reference_params)
        format.html { redirect_to @reference, notice: 'Reference was successfully updated.' }
        format.json { render :show, status: :ok, location: @reference }
      else
        format.html { render :edit }
        format.json { render json: @reference.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /references/1
  # DELETE /references/1.json
  def destroy
    @reference.destroy
    respond_to do |format|
      format.html { redirect_to references_url, notice: 'Reference was successfully destroyed.' }
      format.json { head :no_content }
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

    def check_edit_authorization
      raise User::NotAuthorized unless @reference.can_edit?(current_user)
      @editable = true
    end

    def check_view_authorization
      raise NotAuthorized unless @reference.can_view?(current_user)
      @editable = @reference.can_edit?(current_user)
    end

    def check_create_authorization
      raise NotAuthorized unless @library.can_edit?(current_user)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def reference_params
      params.require(:reference).permit(:key, :title, :bibtex_type, :year, :author_names, :month, fields_attributes: {:name, :value, :id, '_destroy'})
    end
end
