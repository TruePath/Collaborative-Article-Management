#= require active-record-object
#= require filepicker

class @FileManager extends @ActiveRecordObject
	constructor: (obj) ->
		super obj

class @GoogleDriveFileManager extends @FileManager
	constructor: (obj) ->
		super obj
		@type = "DriveFileManager"
		@clientId = window.GoogleClientId
		@apiKey = window.GoogleApiKey

	showPicker: (v, c)->
		view = v
		callback = c
		WaitOnGoogleClient(
			() =>
				@filepicker = new FilePicker(view, callback)
		)

	fileHandleJSON: (metadata) ->
		if metadata.mimeType == "application/vnd.google-apps.folder"
			type = "Folder"
			hash = nil
		else
			type = "Document"
			hash = metadata.md5Checksum
		json =
			metadata: metadata
			fileid: metadata.id
			name: metadata.title
			size: metadata.fileSize
			type: type
			file_hash: hash

	createFileHandle: (json, callback) ->
		$.ajax({
			url: Routes.file_manager_file_handles(@id)
			data: json
			dataType: 'json'
			type: 'POST'
			success: (data) ->
				callback(new FileHandle(data))
			})




@FileManagerFactory = (obj) ->
	switch(obj.type)
		when "DriveFileManager" then return (new GoogleDriveFileManager obj)
		else return (new FileManager obj)


#function selectFileManager(callback) { //requires _select_manager.html.erb to be loaded

