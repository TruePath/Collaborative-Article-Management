class RawBibtexEntriesController < ApplicationController
  before_action :set_raw_bibtex_entry, only: [:show, :edit, :update, :destroy]
  before_action :set_library, only: [:index, :create, :new, :upload]
  before_action :check_edit_authorization [:edit, :update, :destroy]
  before_action :check_create_authorization [:create, :new, :upload]
  before_action :check_view_authorization [:index, :show]

  # GET /raw_bibtex_entries
  # GET /raw_bibtex_entries.json
  def index
    @raw_bibtex_entries = RawBibtexEntry.all
  end

  def upload
   count = @library.raw_bibtex_entries.size
   # bib = BibTex.parse(params[:bibtex_file].read, :filter => :latex,  :parse_names => false, :include => [:errors])
   params[:bibtex_file].read.split(/[\n\r]+  (?=[@]  [[:alpha:]]*?   [{])/xm).each { [entry]

   }
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
    # Use callbacks to share common setup or constraints between actions.
    def set_raw_bibtex_entry
      @raw_bibtex_entry = RawBibtexEntry.find(params[:id])
    end

    def set_library
      @library = Library.find(params[:library_id])
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
end
