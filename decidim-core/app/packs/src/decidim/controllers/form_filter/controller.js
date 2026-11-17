/* eslint-disable id-length */
/* eslint max-lines: ["error", {"max": 350, "skipBlankLines": true}] */

import { Controller } from "@hotwired/stimulus"
import delayed from "src/decidim/refactor/moved/delayed"
import CheckBoxesTree from "src/decidim/refactor/moved/check_boxes_tree"
import { registerCallback, unregisterCallback, pushState, replaceState, state } from "src/decidim/refactor/moved/history"

/**
 * A Stimulus controller that handles the form filter.
 * @class
 * @augments Controller
 */
export default class extends Controller {

  connect() {
    this.id = this.element.id || this._getUID();
    this.mounted = false;
    this.changeEvents = true;
    this.theCheckBoxesTree = new CheckBoxesTree();

    this._updateInitialState();
    this._onFormChange = delayed(this, this._onFormChange.bind(this));
    this._onPopState = this._onPopState.bind(this);
    this._onFilterRefresh = this._onFilterRefresh.bind(this);

    if (window.Decidim.PopStateHandler) {
      this.popStateSubmitter = false;
    } else {
      this.popStateSubmitter = true;
      window.Decidim.PopStateHandler = this.id;
    }

    this.mountComponent()
  }

  /**
   * Handles the logic for unmounting the component
   * @public
   * @returns {Void} - Returns nothing
   */
  disconnect() {
    this.element.removeEventListener("change", this._onFormChange);
    this.element.removeEventListener("form-filter:refresh", this._onFilterRefresh);

    unregisterCallback(`filters-${this.id}`)
  }

  /**
   * Handles the logic for mounting the component
   * @public
   * @returns {Void} - Returns nothing
   */
  mountComponent() {
    if (this.element.length > 0 && !this.mounted) {
      this.mounted = true;
      let queue = 0;

      let contentContainer = document.querySelector("main");
      if (contentContainer.length === 0 && this.element.dataset.remoteFill) {
        contentContainer = this.element.dataset.remoteFill;
      }

      this.element.addEventListener("change", this._onFormChange);
      this.element.addEventListener("form-filter:refresh", this._onFilterRefresh);

      this.currentFormRequest = null;

      this.element.addEventListener("ajax:beforeSend", (e) => {
        if (this.currentFormRequest) {
          this.currentFormRequest.abort();
        }
        this.currentFormRequest = e.detail[0];
        queue += 1;
        if (queue > 0 && contentContainer.length > 0 && !contentContainer.classList.contains("spinner-container")) {
          contentContainer.classList.add("spinner-container");
        }
      });

      document.addEventListener("ajax:success", () => {
        queue -= 1;
        if (queue <= 0 && contentContainer.length > 0) {
          contentContainer.classList.remove("spinner-container");
        }
      });

      document.addEventListener("ajax:error", () => {
        queue -= 1;
        if (queue <= 0 && contentContainer.length > 0) {
          contentContainer.removeClass("spinner-container");
          contentContainer.classlist.add("hide");
        }
      });

      this.theCheckBoxesTree.setContainerForm(this.element);

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

    // The RegExp g flag returns null or an array of coincidences. It does not return the match groups
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
    const orderMenu = this.element.querySelector(".order-by .menu");
    let order = null;

    if (orderMenu) {
      order = orderMenu.querySelector(".menu a").dataset.order;

      if (match) {
        order = match[1];
      }
    }

    return order;
  }

  /**
   * Clears the form to start with a clean state.
   * @private
   * @returns {Void} - Returns nothing.
   */
  _clearForm() {
    this.element.querySelectorAll("input[type=checkbox]").forEach((element) => {
      element.checked = element.indeterminate = false;
    });
    this.element.querySelectorAll("input[type=radio]").forEach((element) => {
      element.checked = false;
    })
    if (this.element.querySelector("fieldset input[type=radio]")) {
      this.element.querySelector("fieldset input[type=radio]").checked = true;
    }
  }

  /**
   * Handles the logic when going back to a previous state in the filter form.
   * @private
   * @returns {Void} - Returns nothing.
   */
  _onPopState() {
    this.changeEvents = false;
    this._clearForm();

    // Prevent filtering again on anchor link "Skip to main content", "Skip map", or "Skip to results"
    const filterSkipValues = [...document.querySelectorAll("[data-skip-to-content]")].map((el) => el.hash);
    if (filterSkipValues.includes(window.location.hash)) {
      return;
    }

    // Remove the origin values retained for a previous history entry. They are
    // added again below when the restored URL still selects them and the
    // corresponding option is not available in the form.
    this.element.querySelectorAll("input[type='hidden'][data-retained-origin]").forEach((input) => input.remove());

    const filterParams = this._parseLocationFilterValues();
    const currentOrder = this._parseLocationOrderValue();

    const orderFilter = this.element.querySelector("input.order_filter");
    if (orderFilter) {
      orderFilter.value = currentOrder;
    }

    if (filterParams) {
      const fieldIds = Object.keys(filterParams);

      // Iterate the filter params and set the correct form values
      fieldIds.forEach((fieldName) => {
        let value = filterParams[fieldName];

        if (Array.isArray(value)) {
          let checkboxes = this.element.querySelectorAll(`input[type=checkbox][name="filter[${fieldName}][]"]`);
          this.theCheckBoxesTree.updateChecked(checkboxes, value);

          if (fieldName === "with_any_origin") {
            this._updateRetainedOrigins(value);
          }
        } else {
          this.element.querySelectorAll(`*[name="filter[${fieldName}]"]`).forEach((element) => {
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

    // Only one instance should submit the form on browser history navigation
    if (this.popStateSubmitter) {
      Rails.fire(this.element, "submit");
    }

    this.changeEvents = true;
  }

  /**
   * Keeps hidden inputs for the origin values that do not have a matching
   * checkbox in the form, so that the selection is still submitted when the
   * available origin options change (for example, when filtering by state).
   * @private
   * @param {Array} values - The origin values to keep selected
   * @returns {Void} - Returns nothing.
   */
  _updateRetainedOrigins(values) {
    this.element.querySelectorAll("input[type='hidden'][data-retained-origin]").forEach((input) => input.remove());

    const checkboxValues = Array.from(this.element.querySelectorAll("input[type='checkbox'][name='filter[with_any_origin][]']:not(.ignore-filter)")).map((checkbox) => checkbox.value);

    values.forEach((value) => {
      if (value === "" || checkboxValues.includes(value)) {
        return;
      }

      const input = document.createElement("input");
      input.type = "hidden";
      input.name = "filter[with_any_origin][]";
      input.value = value;
      input.dataset.retainedOrigin = "true";
      this.element.appendChild(input);
    });
  }

  /**
   * Handles the logic to refresh the widgets of the form when part of it is
   * replaced dynamically, like the origin options when the selected states
   * change.
   * @private
   * @param {CustomEvent} event - The event with the refreshed element in its detail
   * @returns {Void} - Returns nothing.
   */
  _onFilterRefresh(event) {
    if (event.detail && event.detail.element) {
      this.theCheckBoxesTree.refresh(event.detail.element);
    }
  }

  /**
   * Handles the logic to update the current location after a form change event.
   * @private
   * @param {Event} event - The change event
   * @returns {Void} - Returns nothing.
   */
  _onFormChange(event) {
    if (!this.changeEvents) {
      return;
    }

    if (event && (!event.target.matches("input, select") || event.target.matches("[data-disable-dynamic-change]"))) {
      return;
    }

    const [newPath, newState] = this._currentStateAndPath();
    const path = this._getLocation(false);

    if (newPath === path) {
      return;
    }

    Rails.fire(this.element, "submit");
    pushState(newPath, newState);
    this._saveFilters(newPath);
  }

  /**
   * Calculates the path and the state associated to the filters inputs.
   * @private
   * @returns {Array} - Returns an array with the path and the state for the current filters state.
   */
  _currentStateAndPath() {
    const formAction = this.element.action;
    const inputs = this.element.querySelectorAll("input:not(.ignore-filter)");
    const formData = new FormData();
    inputs.forEach((input) => {
      if (input.name && (input.type !== "checkbox" && input.type !== "radio" || input.checked)) {
        formData.append(input.name, input.value);
      }
    });
    const params = new URLSearchParams(formData).toString();

    let path = "";
    let currentState = {};

    if (formAction.indexOf("?") < 0) {
      path = `${formAction}?${params}`;
    } else {
      path = `${formAction}&${params}`;
    }

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

    const pathName = this.element.action;
    sessionStorage.setItem("filteredParams", JSON.stringify({[pathName]: pathWithQueryStrings}));
  }

}
