class LibrariesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_library, only: [:show, :edit, :update, :destroy]
  before_action :check_authorization, only: [:show, :edit, :update, :destroy]
  # respond_to :html, :js

  # GET /libraries
  # GET /libraries.json
  def index
    @libraries = current_user.libraries
  end

  # GET /libraries/1
  # GET /libraries/1.json
  def show
  end

  # GET /libraries/new
  def new
    @library = Library.new
  end

  # GET /libraries/1/edit
  def edit
  end

  # POST /libraries
  # POST /libraries.json
  def create
    @library = Library.new(library_params)
    @library.user = current_user

    respond_to do |format|
      if @library.save
        flash.notice = 'Library was successfully created.'
        format.html { redirect_to libraries_path}
        format.js
      else
        flash.error = 'Error Creating Library.'
        format.html { redirect_to libraries_path }
        format.js
      end
    end
  end

  # PATCH/PUT /libraries/1
  # PATCH/PUT /libraries/1.json
  def update
    respond_to do |format|
      if @library.update(library_params)
        format.html { redirect_to @library, notice: 'Library was successfully updated.' }
        format.json { render :show, status: :ok, location: @library }
      else
        format.html { render :edit }
        format.json { render json: @library.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /libraries/1
  # DELETE /libraries/1.json
  def destroy
    @library.destroy
    respond_to do |format|
      format.html { redirect_to libraries_url, notice: 'Library was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_library
      @library = Library.find(params[:id])
    end

    def check_authorization
      raise User::NotAuthorized unless @library.user == current_user
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def library_params
      params.require(:library).permit(:name)
    end
end
