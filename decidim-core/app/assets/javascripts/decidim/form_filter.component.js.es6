/* eslint-disable no-div-regex, no-useless-escape, no-param-reassign, id-length */

/**
 * A plain Javascript component that handles the form filter.
 * @class
 * @augments Component
 */
((exports) => {
  class FormFilterComponent {
    constructor($form) {
      this.$form = $form;
      this.id = this.$form.attr('id') || this._getUID();
      this.mounted = false;
      this.select2Filters = [];

      this._onFormChange = this._onFormChange.bind(this);
      this._onPopState = this._onPopState.bind(this);

      if (window.Decidim.PopStateHandler) {
        this.popStateSubmiter = false;
      } else {
        this.popStateSubmiter = true;
        window.Decidim.PopStateHandler = this.id;
      }
    }

    /**
     * Handles the logic for unmounting the component
     * @public
     * @returns {Void} - Returns nothing
     */
    unmountComponent() {
      if (this.mounted) {
        this.mounted = false;
        this.$form.off('change', 'input:not(.select2-search__field), select', this._onFormChange);
        this.select2Filters.forEach((select) => {
          select.destroy();
        });

        exports.Decidim.History.unregisterCallback(`filters-${this.id}`)
      }
    }

    /**
     * Handles the logic for mounting the component
     * @public
     * @returns {Void} - Returns nothing
     */
    mountComponent() {
      if (this.$form.length > 0 && !this.mounted) {
        this.mounted = true;
        let select2Filters = this.select2Filters;
        this.$form.find('select.select2').each(function(index, select) {
          select2Filters.push(new window.Decidim.Select2Field(select));
        });
        this.$form.on('change', 'input:not(.select2-search__field), select', this._onFormChange);

        exports.Decidim.History.registerCallback(`filters-${this.id}`, () => {
          this._onPopState();
        });
      }
    }

    /**
     * Finds the current location.
     * @private
     * @returns {String} - Returns the current location.
     */
    _getLocation() {
      return exports.location.toString();
    }

    /**
     * Finds the values of the location params that match the given regexp.
     * @private
     * @param {Regexp} regex - a Regexp to match the params.
     * @returns {String[]} - An array of values of the params that match the regexp.
     */
    _getLocationParams(regex) {
      const location = decodeURIComponent(this._getLocation());
      let values = location.match(regex);
      if (values) {
        values = values.map((val) => val.match(/=(.*)/)[1]);
      }
      return values;
    }

    /**
     * Parse current location and get filter values.
     * @private
     * @returns {Object} - An object where a key correspond to a filter field
     *                     and the value is the current value for the filter.
     */
    _parseLocationFilterValues() {
      // Every location param is constructed like this: filter[key]=value
      let regexpResult = decodeURIComponent(this._getLocation()).match(/filter\[([^\]]*)\](?:\[\])?=([^&]*)/g);

      // The RegExp g flag returns null or an array of coincidences. It doesn't return the match groups
      if (regexpResult) {
        const filterParams = regexpResult.reduce((acc, result) => {
          const [, key, array, value] = result.match(/filter\[([^\]]*)\](\[\])?=([^&]*)/);
          if (array) {
            if (!acc[key]) {
              acc[key]=[];
            }
            acc[key].push(value);
          } else {
            acc[key] = value;
          }
          return acc;
        }, {});

        return filterParams;
      }

      return null;
    }

     /**
     * Parse current location and get the current order.
     * @private
     * @returns {string} - The current order
     */
    _parseLocationOrderValue() {
      const url = this._getLocation();
      const match = url.match(/order=([^&]*)/);
      const $orderMenu = this.$form.find('.order-by .menu');
      let order = $orderMenu.find('.menu a:first').data('order');

      if (match) {
        order = match[1];
      }

      return order;
    }

    /**
     * Clears the form to start with a clean state.
     * @private
     * @returns {Void} - Returns nothing.
     */
    _clearForm() {
      this.$form.find('input[type=checkbox]').attr('checked', false);
      this.$form.find('input[type=radio]').attr('checked', false);
      this.$form.find('select.select2').val(null).trigger('change.select2');

      // This ensure the form is reset in a valid state where a fieldset of
      // radio buttons has the first selected.
      this.$form.find('fieldset input[type=radio]:first').each(function () {
        // I need the this to iterate a jQuery collection
        $(this)[0].checked = true; // eslint-disable-line no-invalid-this
      });
    }

    /**
     * Handles the logic when going back to a previous state in the filter form.
     * @private
     * @returns {Void} - Returns nothing.
     */
    _onPopState() {
      this._clearForm();

      const filterParams = this._parseLocationFilterValues();
      const currentOrder = this._parseLocationOrderValue();

      this.$form.find('input.order_filter').val(currentOrder);

      if (filterParams) {
        const fieldIds = Object.keys(filterParams);

        // Iterate the filter params and set the correct form values
        fieldIds.forEach((fieldId) => {
          let field = null;

          // Since we are using Ruby on Rails generated forms the field ids for a
          // checkbox or a radio button has the following form: filter_${key}_${value}
          field = this.$form.find(`input#filter_${fieldId}_${filterParams[fieldId]}`);

          if (field.length > 0) {
            field[0].checked = true;
          } else {
            // If the field is not a checkbox neither a radio it means is a input or a select.
            // Ruby on Rails ensure the ids are constructed like this: filter_${key}
            field = this.$form.find(`input#filter_${fieldId},select#filter_${fieldId}`);

            if (field.length > 0) {
              if (field.hasClass("select2")) {
                field.val(filterParams[fieldId]).trigger('change.select2');
              } else {
                field.val(filterParams[fieldId]);
              }
            }
          }
        });
      }

      // Only one instance should submit the form on browser history navigation
      if (this.popStateSubmiter) {
        exports.Rails.fire(this.$form[0], 'submit');
      }
    }

    /**
     * Handles the logic to update the current location after a form change event.
     * @private
     * @returns {Void} - Returns nothing.
     */
    _onFormChange() {
      const formAction = this.$form.attr('action');
      const params = this.$form.serialize();

      let newUrl = '';

      exports.Rails.fire(this.$form[0], 'submit');

      if (formAction.indexOf('?') < 0) {
        newUrl = `${formAction}?${params}`;
      } else {
        newUrl = `${formAction}&${params}`;
      }

      exports.Decidim.History.pushState(newUrl);
    }

    /**
     * Generates a unique identifier for the form.
     * @private
     * @returns {String} - Returns a unique identifier
     */
    _getUID() {
      return `filter-form-${new Date().setUTCMilliseconds()}-${Math.floor(Math.random() * 10000000)}`;
    }
  }

  exports.Decidim = exports.Decidim || {};
  exports.Decidim.FormFilterComponent = FormFilterComponent;
})(window);
