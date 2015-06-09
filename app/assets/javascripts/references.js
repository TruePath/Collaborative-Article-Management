// Generated by CoffeeScript 1.9.3
(function() {
  $(document).on('nested:fieldAdded:fields', function(event) {
    var field, fieldset, label;
    fieldset = event.field;
    label = fieldset.find('.field_name_label').first();
    field = fieldset.find('.field_name').first();
    $('#new-field-modal').modal('show');
    $('#cancel-new-field').click(function(event) {
      $('#new-field-modal').modal('hide');
      fieldset.remove();
      $('#cancel-new-field').off();
      $('#new-field-name-form').off();
      event.preventDefault();
    });
    $('#new-field-name-form').submit(function(event) {
      var fieldname, regx;
      fieldname = $.trim($('#new-field-name').val());
      regx = /^[A-Za-z0-9_]+$/;
      if (!regx.test(fieldname)) {
        $('#invalid_field').show();
      } else {
        $('#invalid_field').hide();
        field.val(fieldname);
        label.text(fieldname);
        $('#cancel-new-field').off();
        $('#new-field-name-form').off();
        $('#new-field-modal').modal('hide');
      }
      event.preventDefault();
    });
  });

}).call(this);
