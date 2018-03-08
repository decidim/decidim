$(() => {
  ((exports) => {
    const $assemblyScopeEnabled = $('#assembly_scopes_enabled');
    const $assemblyScopeId = $("#assembly_scope_id");

    if ($('.edit_assembly, .new_assembly').length > 0) {
      $assemblyScopeEnabled.on('change', (event) => {
        const checked = event.target.checked;
        exports.theDataPicker.enabled($assemblyScopeId, checked);
      })
      exports.theDataPicker.enabled($assemblyScopeId, $assemblyScopeEnabled.prop('checked'));
    }

    const $checkbox = $('#assembly_has_closed');
    const $closingDateInput = $('#closing_date_div');
    const $closingDateReasonInput = $('#closing_date_reason_div');

    if ($checkbox.length > 0) {
      const toggleInput = () => {
        if ($checkbox[0].checked) {
          $closingDateInput.show();
          $closingDateReasonInput.show();
        } else {
          $closingDateInput.hide();
          $closingDateReasonInput.hide();
        }
      }
      toggleInput();
      $checkbox.on('change', toggleInput);
    }

    (function( $ ){

      $.fn.dependsOn = function(element, value) {
        var elements = this;
        var hideOrShow = function() {
          var $this = $(this);
          var showEm;
          if ( $this.is('input[type="checkbox"]') ) {
            showEm = !$this.is(':checked');
          } else if ($this.is('select')) {
            var fieldValue = $this.find('option:selected').val();
            if (typeof(value) == 'undefined') {
              showEm = fieldValue && $.trim(fieldValue) != '';
            } else if ($.isArray(value)) {
              showEm = $.inArray(fieldValue, value.map(function(v) {return v.toString()})) >= 0;
            } else {
              showEm = value.toString() == fieldValue;
            }
          }
          elements.toggle(showEm);
        }
        //add change handler to element
        $(element).change(hideOrShow);

        //hide the dependent fields
        $(element).each(hideOrShow);

        return elements;
      };

      $(document).on('ready page:load', function() {
        $('*[data-depends-on]').each(function() {
          var $this = $(this);
          var master = $this.data('dependsOn').toString();
          var value = $this.data('dependsOnValue');
          if (typeof(value) != 'undefined') {
            $this.dependsOn(master, value);
          } else {
            $this.dependsOn(master);
          }
        });

        $("#assembly_closing_date").on("change", function(){
          alert("holllaaaa");
        });
      });

    })( jQuery );
  })(window);
});
