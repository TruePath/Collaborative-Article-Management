(function() {
	/**
	 * Initialise a Google Driver file picker
	 */
	var FilePicker = window.FilePicker = function(view, callback) {
		// Config
		if ($.type(view) === "string") {
			switch (view) {
				case "FOLDER":
					this.view = (google.picker.ViewId.FOLDERS);
					break;
				case "DOCUMENTS":
				case "DOCS":
					this.view = google.picker.ViewId.DOCUMENTS;
					break;
				case "PDF":
					this.view = google.picker.ViewId.PDFS;
					break;
				case "RECENT":
					this.view = google.picker.ViewId.RECENTLY_PICKED;
					break;
				case "ALL":
					this.view = google.picker.ViewId.DOCS;
					break;
			}
		} else {
			this.view = view;
		}
		this.apiKey = window.GoogleApiKey;
		this.clientId = window.GoogleClientId;

		this.apiLoadedDfd = jQuery.Deferred();

		// Events
		this.onSelect = callback;


		// Load the drive API
		gapi.client.setApiKey(this.apiKey);
		gapi.client.load('drive', 'v2', this._driveApiLoaded.bind(this));
		google.load('picker', '1', { callback: this._pickerApiLoaded.bind(this) });
	};

	FilePicker.prototype = {
		/**
		 * Open the file picker.
		 */
		open: function() {
			// Check if the user has already authenticated
			var token = gapi.auth.getToken();
			if (token) {
				this._showPicker();
			} else {
				// The user has not yet authenticated with Google
				// We need to do the authentication before displaying the Drive picker.
				this._doAuth(false, function() { this._showPicker(); }.bind(this));
			}
		},

		/**
		 * Show the file picker once authentication has been done.
		 * @private
		 */
		_showPicker: function() {
			var accessToken = gapi.auth.getToken().access_token;
			this.picker = new google.picker.PickerBuilder().
				addView(this.view).
				setAppId(this.clientId).
				setOAuthToken(accessToken).
				setCallback(this._pickerCallback.bind(this)).
				build().
				setVisible(true);
		},

		/**
		 * Called when a file has been selected in the Google Drive file picker.
		 * @private
		 */
		_pickerCallback: function(data) {
			if (data[google.picker.Response.ACTION] == google.picker.Action.PICKED) {
				var file = data[google.picker.Response.DOCUMENTS][0],
					id = file[google.picker.Document.ID],
					request = gapi.client.drive.files.get({
						fileId: id
					});

				request.execute(this._fileGetCallback.bind(this));
			}
		},

// 		Document.ADDRESS_LINES	The address of the picked location.
// Document.AUDIENCE	An Audience type used to convey the audience of a Picasa Web Album.
// Document.DESCRIPTION	A user-contributed description of the picked item.
// Document.DURATION	The duration of a picked video.
// Document.EMBEDDABLE_URL	A URL for this item suitable for embedding in a web page.
// Document.ICON_URL	A URL to an icon for this item.
// Document.ID	The id for the picked item.
// Document.IS_NEW	Returns true if the picked item was just uploaded.
// Document.LAST_EDITED_UTC	The timestamp describing when this item was last edited.
// Document.LATITUDE	The latitude of the picked location.
// Document.LONGITUDE	The longitude of the picked location.
// Document.MIME_TYPE	The MIME type of this item.
// Document.NAME	The name of this item.
// Document.NUM_CHILDREN	The number of children contained in this item. For example, the number of photos in a selected album.
// Document.PARENT_ID	The parent id of this item. For example, the album which contains this photo.
// Document.PHONE_NUMBERS	The phone number of the picked location.
// Document.SERVICE_ID	A ServiceId describing the service this item was picked from.
// Document.THUMBNAILS	An array of Thumbnails which describe the attributes of a photo or video. Thumbnails will not be returned if the picked items belong to Google Drive.
// Document.TYPE	The Type of the picked item.
// Document.URL	A URL to this item.
		/**
		 * Called when file details have been retrieved from Google Drive.
		 * @private
		 */
		_fileGetCallback: function(file) {
			if (this.onSelect) {
				this.onSelect(file);
			}
		},

		/**
		 * Called when the Google Drive file picker API has finished loading.
		 * @private
		 */
		_pickerApiLoaded: function() {
			this.apiLoadedDfd.resolve();
		},

		/**
		 * Called when the Google Drive API has finished loading.
		 * @private
		 */
		_driveApiLoaded: function() {
			this._doAuth(true);
			this.apiLoadedDfd.done(this.open.bind(this));
		},

		/**
		 * Authenticate with Google Drive via the Google JavaScript API.
		 * @private
		 */
		_doAuth: function(immediate, callback) {
			gapi.auth.authorize({
				client_id: this.clientId + '.apps.googleusercontent.com',
				scope: 'https://www.googleapis.com/auth/drive.readonly',
				immediate: immediate
			}, callback);
		}
	};
}());