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
      this.id = this.$form.attr("id") || this._getUID();
      this.mounted = false;
      this.changeEvents = true;

      this._updateInitialState();
      this._onFormChange = exports.delayed(this, this._onFormChange.bind(this));
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
        this.$form.off("change", "input, select", this._onFormChange);

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

        this.$form.on("change", "input:not([data-disable-dynamic-change]), select:not([data-disable-dynamic-change])", this._onFormChange);

        this.currentFormRequest = null;
        this.$form.on("ajax:beforeSend", (e) => {
          if (this.currentFormRequest) {
            this.currentFormRequest.abort();
          }
          this.currentFormRequest = e.originalEvent.detail[0];
        });

        exports.theCheckBoxesTree.setContainerForm(this.$form);

        exports.Decidim.History.registerCallback(`filters-${this.id}`, (state) => {
          this._onPopState(state);
        });
      }
    }

    /**
     * Sets path in the browser history with the initial filters state, to allow to restoring it when using browser history.
     * @private
     * @returns {Void} - Returns nothing.
     */
    _updateInitialState() {
      const [initialPath, initialState] = this._currentStateAndPath();
      initialState._path = initialPath
      exports.Decidim.History.replaceState(null, initialState);
    }

    /**
     * Finds the current location.
     * @param {boolean} withHost - include the host part in the returned location
     * @private
     * @returns {String} - Returns the current location.
     */
    _getLocation(withHost = true) {
      const state = exports.Decidim.History.state();
      let path = "";

      if (state && state._path) {
        path = state._path;
      } else {
        path = exports.location.pathname + exports.location.search + exports.location.hash;
      }

      if (withHost) {
        return exports.location.origin + path;
      }
      return path;
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
              acc[key] = [];
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
      const $orderMenu = this.$form.find(".order-by .menu");
      let order = $orderMenu.find(".menu a:first").data("order");

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
      this.$form.find("input[type=checkbox]").each((index, element) => {
        element.checked = element.indeterminate = false;
      });
      this.$form.find("input[type=radio]").attr("checked", false);
      this.$form.find(".data-picker").each((_index, picker) => {
        exports.theDataPicker.clear(picker);
      });

      // This ensure the form is reset in a valid state where a fieldset of
      // radio buttons has the first selected.
      this.$form.find("fieldset input[type=radio]:first").each(function () {
        // I need the this to iterate a jQuery collection
        $(this)[0].checked = true; // eslint-disable-line no-invalid-this
      });
    }

    /**
     * Handles the logic when going back to a previous state in the filter form.
     * @private
     * @param {Object} state - state stored along with location URL
     * @returns {Void} - Returns nothing.
     */
    _onPopState(state) {
      this.changeEvents = false;
      this._clearForm();

      const filterParams = this._parseLocationFilterValues();
      const currentOrder = this._parseLocationOrderValue();

      this.$form.find("input.order_filter").val(currentOrder);

      if (filterParams) {
        const fieldIds = Object.keys(filterParams);

        // Iterate the filter params and set the correct form values
        fieldIds.forEach((fieldName) => {
          let value = filterParams[fieldName];

          if (Array.isArray(value)) {
            let checkboxes = this.$form.find(`input[type=checkbox][name="filter[${fieldName}][]"]`);
            window.theCheckBoxesTree.updateChecked(checkboxes, value);
          } else {
            this.$form.find(`*[name="filter[${fieldName}]"]`).each((index, element) => {
              switch (element.type) {
              case "hidden":
                break;
              case "radio":
              case "checkbox":
                element.checked = value === element.value;
                break;
              default:
                element.value = value;
              }
            });
          }
        });
      }

      // Retrieves picker information for selected values (value, text and link) from the state object
      $(".data-picker", this.$form).each((_index, picker) => {
        let pickerState = state[picker.id];
        if (pickerState) {
          exports.theDataPicker.load(picker, pickerState);
        }
      })

      // Only one instance should submit the form on browser history navigation
      if (this.popStateSubmiter) {
        exports.Rails.fire(this.$form[0], "submit");
      }

      this.changeEvents = true;
    }

    /**
     * Handles the logic to update the current location after a form change event.
     * @private
     * @returns {Void} - Returns nothing.
     */
    _onFormChange() {
      if (!this.changeEvents) {
        return;
      }

      const [newPath, newState] = this._currentStateAndPath();
      const path = this._getLocation(false);

      if (newPath === path) {
        return;
      }

      exports.Rails.fire(this.$form[0], "submit");
      exports.Decidim.History.pushState(newPath, newState);
    }

    /**
     * Calculates the path and the state associated to the filters inputs.
     * @private
     * @returns {Array} - Returns an array with the path and the state for the current filters state.
     */
    _currentStateAndPath() {
      const formAction = this.$form.attr("action");
      const params = this.$form.find(":not(.ignore-filters)").find("select:not(.ignore-filter), input:not(.ignore-filter)").serialize();

      let path = "";
      let state = {};

      if (formAction.indexOf("?") < 0) {
        path = `${formAction}?${params}`;
      } else {
        path = `${formAction}&${params}`;
      }

      // Stores picker information for selected values (value, text and link) in the state object
      $(".data-picker", this.$form).each((_index, picker) => {
        state[picker.id] = exports.theDataPicker.save(picker);
      })

      return [path, state];
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
