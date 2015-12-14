class FileHandlesController < ApplicationController
  before_action :set_file_handle, only: [:show, :edit, :update, :destroy]

  # GET /resources
  # GET /resources.json
  def index
    @file_handles = FileHandle.all
  end

  # GET /file_handles/1
  # GET /file_handles/1.json
  def show
  end

  # GET /file_handles/new
  def new
    @file_handle = FileHandle.new
  end

  # GET /file_handles/1/edit
  def edit
  end

  # POST /file_handles
  # POST /file_handles.json
  def create
    @file_handle = FileHandle.new(file_handle_params)

    respond_to do |format|
      if @file_handle.save
        format.html { redirect_to @file_handle, notice: 'FileHandle was successfully created.' }
        format.json { render :show, status: :created, location: @file_handle }
      else
        format.html { render :new }
        format.json { render json: @file_handle.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /file_handles/1
  # PATCH/PUT /file_handles/1.json
  def update
    respond_to do |format|
      if @file_handle.update(file_handle_params)
        format.html { redirect_to @file_handle, notice: 'FileHandle was successfully updated.' }
        format.json { render :show, status: :ok, location: @file_handle }
      else
        format.html { render :edit }
        format.json { render json: @file_handle.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /file_handles/1
  # DELETE /file_handles/1.json
  def destroy
    @file_handle.destroy
    respond_to do |format|
      format.html { redirect_to file_handles_url, notice: 'FileHandle was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_file
      @file_handle = File.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def file_params
      params.require(:file_handle).permit(:name, :file_hash, :metadata, :size, :fileid, :type)
    end
end