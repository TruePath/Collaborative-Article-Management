class RawBibtexEntriesController < ApplicationController
  before_action :set_raw_bibtex_entry, only: [:show, :edit, :update, :destroy]
  before_action :set_library, only: [:index, :create, :new, :upload, :delete, :import]
  before_action :set_raw_bibtex_entries, only: [:delete, :import]
  before_action :check_edit_authorization, only:  [:edit, :update, :destroy]
  before_action :check_multiple_edit_authorization, only: [:delete, :import]
  before_action :check_create_authorization, only:  [:create, :new, :upload]
  before_action :check_view_authorization, only:  [:index, :show]

  helper_method :sort_by, :sort_direction, :preserve_params

  # GET /raw_bibtex_entries
  # GET /raw_bibtex_entries.json
  def index
    @page = params[:page] || 0
    @raw_bibtex_entries = RawBibtexEntry.where(library: @library).order(sort_by + " " + sort_direction).filter(search_params).page @page
    @sort_column = sort_by
  end

  def upload
   raise NotAuthorized unless @library
   bfile = BibtexFile.new
   bfile.library = @library
   bfile.references_source = params[:bibtex_file]
   bfile.save
   @jid = BibtexUploadWorker.create(bibtex_file_id: bfile.id, library_id: @library.id)
  end

  def delete
    @raw_bibtex_entries.delete_all
    # @raw_bibtex_entries.each {|entry| entry.destroy}
    respond_to do |format|
      format.js { render 'refresh', notice: 'Entries Deleted'}
    end
  end

  def import
  end

  # GET /raw_bibtex_entries/1
  # GET /raw_bibtex_entries/1.json
  def show
  end

  # GET /raw_bibtex_entries/new
  def new
    @raw_bibtex_entry = RawBibtexEntry.new
  end

  # GET /raw_bibtex_entries/1/edit
  def edit
  end

  # POST /raw_bibtex_entries
  # POST /raw_bibtex_entries.json
  def create
    @raw_bibtex_entry = RawBibtexEntry.new(raw_bibtex_entry_params)

    respond_to do |format|
      if @raw_bibtex_entry.save
        format.html { redirect_to @raw_bibtex_entry, notice: 'Raw bibtex entry was successfully created.' }
        format.json { render :show, status: :created, location: @raw_bibtex_entry }
      else
        format.html { render :new }
        format.json { render json: @raw_bibtex_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /raw_bibtex_entries/1
  # PATCH/PUT /raw_bibtex_entries/1.json
  def update
    respond_to do |format|
      if @raw_bibtex_entry.update(raw_bibtex_entry_params)
        format.html { redirect_to @raw_bibtex_entry, notice: 'Raw bibtex entry was successfully updated.' }
        format.json { render :show, status: :ok, location: @raw_bibtex_entry }
      else
        format.html { render :edit }
        format.json { render json: @raw_bibtex_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /raw_bibtex_entries/1
  # DELETE /raw_bibtex_entries/1.json
  def destroy
    @raw_bibtex_entry.destroy
    respond_to do |format|
      format.html { redirect_to raw_bibtex_entries_url, notice: 'Raw bibtex entry was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def sort_by
      RawBibtexEntry.column_names.include?(params[:sort_by]) ? params[:sort_by] : "created_at"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end


    # Use callbacks to share common setup or constraints between actions.
    def set_raw_bibtex_entry
      @raw_bibtex_entry = RawBibtexEntry.find(params[:id])
    end

    def set_library
      @library = Library.find(params[:library_id])
    end

    def set_raw_bibtex_entries
      if  params[:select_all].present? && params[:select_all].to_bool
        @raw_bibtex_entries = RawBibtexEntry.where(library: @library).filter(search_params)
      else
        @raw_bibtex_entries = RawBibtexEntry.find(params[:raw_bibtex_entry_ids])
      end
    end

    def check_multiple_edit_authorization
      raise NotAuthorized unless @library.can_edit?(current_user)
      return if  params[:select_all].present? && params[:select_all].to_bool
      raise NotAuthorized unless @raw_bibtex_entries.all? { |entry| entry.library == @library }
    end

    def check_edit_authorization
      return if !@library.nil? && @library.can_edit?(current_user)
      raise NotAuthorized unless @raw_bibtex_entry.can_edit?(current_user)
    end

    def check_view_authorization
      return if !@library.nil? && @library.can_view?(current_user)
      raise NotAuthorized unless @raw_bibtex_entry.can_view?(current_user)
    end


    def check_create_authorization
      raise NotAuthorized unless @library.can_edit?(current_user)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def raw_bibtex_entry_params
      params[:raw_bibtex_entry]
    end

    def preserve_params
      return params.slice(:has_errors, :has_warnings, :converted, :contains, :sort_by, :sort_direction)
    end

    def search_params
      return params.slice(:has_errors, :has_warnings, :converted, :contains)
    end

end
