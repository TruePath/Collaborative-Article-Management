// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require bootstrap
//= require_tree .

// FLASH NOTICE ANIMATION
var fade_flash = function() {
  $("#flash_notice").delay(5000).fadeOut("slow");
  $("#flash_alert").delay(5000).fadeOut("slow");
  $("#flash_error").delay(5000).fadeOut("slow");
  $("#flash_success").delay(5000).fadeOut("slow");
};
fade_flash();

var show_ajax_flash = function(msg, type) {
	switch(type) {
		case "error":
    	$("#flash-message").html('<div id="flash_error" class="alert alert-danger">'+msg+'</div>');
    	break;
    case "alert":
    	$("#flash-message").html('<div id="flash_alert" class="alert alert-warning">'+msg+'</div>');
    	break;
    case "notice":
    	$("#flash-message").html('<div id="flash_notice" class="alert alert-info">'+msg+'</div>');
    	break;
    default:
    	$("#flash-message").html('<div id="flash_success" class="alert alert-success">'+msg+'</div>');
  }
    fade_flash();
};

$(document).ajaxComplete(function(event, request) {
    var msg = request.getResponseHeader('X-Message');
    var type = request.getResponseHeader('X-Message-Type');
    if (msg) show_ajax_flash(msg, type); //use whatever popup, notification or whatever plugin you want
});
