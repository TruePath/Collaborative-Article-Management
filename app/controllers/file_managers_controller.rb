class FileManagersController < ApplicationController
	before_action :authenticate_user!

	def new
		session[:return_to] = request.referer
	end

	def create_oauth2_file_manager
		@user = current_user
		case params[:type]
		when "DriveFileManager"
			@file_manager = DriveFileManager.create(user: @user)
		end
		auth_uri = @file_manager.auth_uri
		session[:file_manager] = @file_manager.id
		respond_to do |format|
			format.js { render js: "window.location = '#{auth_uri}'"  }
			format.html {redirect_to auth_uri }
		end
	end

	def oauth2_callback
		@file_manager = FileManager.find(session[:file_manager])
 		if request['code'] == nil
 			redirect_to(@file_manager.auth_uri)
 		else
 			@file_manager.accept_callback(request['code'], request['state'])
 			return_to = session[:return_to] || home_index_path
 			session[:return_to] = nil
 			session[:file_manager] = nil
 			redirect_to(return_to)
 		end
	end
end