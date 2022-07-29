/* eslint-disable no-div-regex, no-useless-escape, no-param-reassign, id-length */
/* eslint max-lines: ["error", {"max": 350, "skipBlankLines": true}] */

/**
 * A plain Javascript component that handles the form filter.
 * @class
 * @augments Component
 */

import delayed from "src/decidim/delayed"
import CheckBoxesTree from "src/decidim/check_boxes_tree"
import { registerCallback, unregisterCallback, pushState, replaceState, state } from "src/decidim/history"
import DataPicker from "src/decidim/data_picker"

export default class FormFilterComponent {
  constructor($form) {
    this.$form = $form;
    this.id = this.$form.attr("id") || this._getUID();
    this.mounted = false;
    this.changeEvents = true;
    this.theCheckBoxesTree = new CheckBoxesTree();
    this.theDataPicker = window.theDataPicker || new DataPicker($(".data-picker"));

    this._updateInitialState();
    this._onFormChange = delayed(this, this._onFormChange.bind(this));
    this._onFormSubmit = delayed(this, this._onFormSubmit.bind(this));
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
      this.$form.off("submit", this._onFormSubmit);

      unregisterCallback(`filters-${this.id}`)
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
      let queue = 0;

      let contentContainer = $(this.$form.closest(".filters").parent().find(".skip").attr("href"));
      if (contentContainer.length === 0 && this.$form.data("remoteFill")) {
        contentContainer = this.$form.data("remoteFill");
      }
      this.$form.on("change", "input:not([data-disable-dynamic-change]), select:not([data-disable-dynamic-change])", this._onFormChange);
      this.$form.on("submit", this._onFormSubmit);

      this.currentFormRequest = null;
      this.$form.on("ajax:beforeSend", (e) => {
        if (this.currentFormRequest) {
          this.currentFormRequest.abort();
        }
        this.currentFormRequest = e.originalEvent.detail[0];
        queue += 1;
        if (queue > 0 && contentContainer.length > 0 && !contentContainer.hasClass("spinner-container")) {
          contentContainer.addClass("spinner-container");
        }
      });

      this.$form.on("ajax:success", () => {
        queue -= 1;
        if (queue <= 0 && contentContainer.length > 0) {
          contentContainer.removeClass("spinner-container");
        }
      });

      this.$form.on("ajax:error", () => {
        queue -= 1;
        if (queue <= 0 && contentContainer.length > 0) {
          contentContainer.removeClass("spinner-container");
        }
        this.$form.find(".spinner-container").addClass("hide");
      });

      this.theCheckBoxesTree.setContainerForm(this.$form);

      registerCallback(`filters-${this.id}`, (currentState) => {
        this._onPopState(currentState);
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
    replaceState(null, initialState);
  }

  /**
   * Finds the current location.
   * @param {boolean} withHost - include the host part in the returned location
   * @private
   * @returns {String} - Returns the current location.
   */
  _getLocation(withHost = true) {
    const currentState = state();
    let path = "";

    if (currentState && currentState._path) {
      path = currentState._path;
    } else {
      path = window.location.pathname + window.location.search + window.location.hash;
    }

    if (withHost) {
      return window.location.origin + path;
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
      this.theDataPicker.clear(picker);
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
   * @param {Object} currentState - state stored along with location URL
   * @returns {Void} - Returns nothing.
   */
  _onPopState(currentState) {
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
          this.theCheckBoxesTree.updateChecked(checkboxes, value);
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
      let pickerState = currentState[picker.id];
      if (pickerState) {
        this.theDataPicker.load(picker, pickerState);
      }
    })

    // Only one instance should submit the form on browser history navigation
    if (this.popStateSubmiter) {
      Rails.fire(this.$form[0], "submit", { from: "pop" });
    }

    this.changeEvents = true;
  }

  /**
   * Handles the logic to decide whether the form should be submitted or not
   * after a form change event. The form is only submitted when changes have
   * occurred.
   * @private
   * @returns {Void} - Returns nothing.
   */
  _onFormChange() {
    if (!this.changeEvents) {
      return;
    }

    const [newPath] = this._currentStateAndPath();
    const path = this._getLocation(false);

    if (newPath === path) {
      return;
    }

    Rails.fire(this.$form[0], "submit");
  }

  /**
   * Saves the current state of the search on form submit to update the search
   * parameters to the URL and store the picker states.
   * @private
   * @param {jQuery.Event} ev The event that caused the form to submit.
   * @returns {Void} - Returns nothing.
   */
  _onFormSubmit(ev) {
    const eventDetail = ev.originalEvent.detail;
    if (eventDetail && eventDetail.from === "pop") {
      return;
    }

    const [newPath, newState] = this._currentStateAndPath();

    pushState(newPath, newState);
    this._saveFilters(newPath);
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
    let currentState = {};

    if (formAction.indexOf("?") < 0) {
      path = `${formAction}?${params}`;
    } else {
      path = `${formAction}&${params}`;
    }

    // Stores picker information for selected values (value, text and link) in the currentState object
    $(".data-picker", this.$form).each((_index, picker) => {
      currentState[picker.id] = this.theDataPicker.save(picker);
    })

    return [path, currentState];
  }

  /**
   * Generates a unique identifier for the form.
   * @private
   * @returns {String} - Returns a unique identifier
   */
  _getUID() {
    return `filter-form-${new Date().getUTCMilliseconds()}-${Math.floor(Math.random() * 10000000)}`;
  }

  /**
   * Saves the changed filters on sessionStorage API.
   * @private
   * @param {string} pathWithQueryStrings - path with all the query strings for filter. To be used with backToListLink().
   * @returns {Void} - Returns nothing.
   */
  _saveFilters(pathWithQueryStrings) {
    if (!window.sessionStorage) {
      return;
    }

    const pathName = this.$form.attr("action");
    sessionStorage.setItem("filteredParams", JSON.stringify({[pathName]: pathWithQueryStrings}));
  }

}
