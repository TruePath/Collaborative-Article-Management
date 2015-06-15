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
//= require jquery.cookie
//= require jquery_ujs
//= require jquery.remotipart
//= require turbolinks
//= require bootstrap
//= require jquery_nested_form
//= require_tree .

(function($) {
    if (!$.outerHTML) {
        $.extend({
            outerHTML: function(ele) {
                var $return;
                if (ele.length === 1) {
                    $return = ele[0].outerHTML;
                }
                else if (ele.length > 1) {
                    $return = {};
                    ele.each(function(i) {
                        $return[i] = $(this)[0].outerHTML;
                    });
                }
                return $return;
            }
        });
        $.fn.extend({
            outerHTML: function() {
                return $.outerHTML($(this));
            }
        });
    }
})(jQuery);

function ListDeleteController(container) {
  this.container = container;
  this.container.find('.delete-indicator').hide();
  this.DeletedItem = null;
  this.modal = container.find('.confirm-delete-modal').first();
  this.enable_button = this.container.find('.enable-delete-button').first();
  this.enable_button.click($.proxy(this.enable_delete, this));
  this.disable_button = this.container.find('.finish-delete-button').first();
  this.disable_button.click($.proxy(this.disable_delete, this));
  this.confirm_button = this.modal.find('.confirm-delete-button');
  this.disable_delete();
}

ListDeleteController.prototype.enable_delete = function() {
  this.container.find('.delete-indicator').show();
  this.enable_button.hide();
  this.disable_button.show();
  modal = this.modal;
  container = this.container;
  deletecontroller = this;
  this.container.find('.deleteable-element').off("click");
  this.container.find('.deleteable-element').click( function(e) {
    e.preventDefault();
    content = "";
    if ($(this).is('.deleteable-identifier')) {
      content = $(this).html();
    } else {
      content = $(this).find('.deleteable-identifier').first().html();
    }
    modal.find('.confirm-delete-content').html(content);
    modal.modal('show');
    url = $(this).is('.deleteable-href') ? this.href : $(this).find('.deleteable-href').attr("href");
    deletecontroller.DeletedItem = $(this);
    modal.find('.confirm-delete-button').first().click(function() {
      $.ajax({
        url: url,
        dataType: "script",
        type: 'DELETE'
      });
    });
  });
};

ListDeleteController.prototype.disable_delete = function() {
  this.container.find('.delete-indicator').hide();
  this.container.find('.deleteable-element').off("click");
  this.enable_button.show();
  this.disable_button.hide();
  modal = this.modal;
  container = this.container;
  this.container.find('.deleteable-element').click( function(e) {
    e.preventDefault();
    url = $(this).is('.deleteable-href') ? this.href : $(this).find('.deleteable-href').attr("href");
    $.getScript(url);
  });
};

$.cookie.json = true; // use json to store cookie information
// FLASH NOTICE ANIMATION
var fade_flash = function() {
  $("#flash_notice").delay(5000).fadeOut("slow");
  $("#flash_alert").delay(5000).fadeOut("slow");
  $("#flash_error").delay(5000).fadeOut("slow");
  $("#flash_success").delay(5000).fadeOut("slow");
};

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

// Code to enable multiple modals
$(document).ready(function() {
  fade_flash();
  // Code to enable multiple modals
  $('.modal').on('hidden.bs.modal', function( event ) {
    $(this).removeClass( 'fv-modal-stack' );
    $('body').data( 'fv_open_modals', $('body').data( 'fv_open_modals' ) - 1 );
  });

  $( '.modal' ).on( 'shown.bs.modal', function ( event ) {
    // keep track of the number of open modals
    if ( typeof( $('body').data( 'fv_open_modals' ) ) == 'undefined' ) {
     $('body').data( 'fv_open_modals', 0 );
    }

    // if the z-index of this modal has been set, ignore.
    if ( $(this).hasClass( 'fv-modal-stack' ) ) {
      return;
    }

    $(this).addClass( 'fv-modal-stack' );
    $('body').data( 'fv_open_modals', $('body').data( 'fv_open_modals' ) + 1 );
    $(this).css('z-index', 1040 + (10 * $('body').data( 'fv_open_modals' )));
    $( '.modal-backdrop' ).not( '.fv-modal-stack' ).css( 'z-index', 1039 + (10 * $('body').data( 'fv_open_modals' )));
    $( '.modal-backdrop' ).not( 'fv-modal-stack' ).addClass( 'fv-modal-stack' );
  });

});






