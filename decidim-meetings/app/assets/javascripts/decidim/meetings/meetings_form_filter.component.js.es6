/* eslint-disable no-div-regex, no-useless-escape, no-param-reassign */

/**
 * A component that handles the meetings filter form.
 * @class
 * @augments Component
 */
((exports) => {
  class MeetingsFormFilterComponent {
    constructor(selector) {
      this.$form = $(selector);
      this.mounted = false;

      this._onFormChange = this._onFormChange.bind(this);
      this._onPopState = this._onPopState.bind(this);
    }

    /**
     * Handles the logic for unmounting the component
     * @public
     * @returns {Void} - Returns nothing
     */
    unmountComponent() {
      if (this.mounted) {
        this.mounted = false;
        this.$form.off('change', 'input, select', this._onFormChange);

        exports.onpopstate = null;
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
        this.$form.on('change', 'input, select', this._onFormChange);

        exports.onpopstate = this._onPopState;
      }
    }

    /**
     * Finds the current location.
     * @private
     * @returns {String} - Returns the current location.
     */
    _getLocation() {
      return exports.location;
    }

    /**
     * Finds the values of the location prams that match the given regexp.
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
     * Clears the form to start with a clean state.
     * @private
     * @returns {Void} - Returns nothing.
     */
    _clearForm() {
      this.$form.find('input[type=checkbox]').attr('checked', false);
      this.$form.find('input[type=radio]').attr('checked', false);
    }

    /**
     * Handles the logic when going back to a previous state in the filter form.
     * @private
     * @returns {Void} - Returns nothing.
     */
    _onPopState() {
      this._clearForm();

      let [sortValue] = this._getLocationParams(/order_start_time=([^&]*)/g) || ["asc"];
      this.$form.find(`input[type=radio][value=${sortValue}]`)[0].checked = true;

      let scopeValues = this._getLocationParams(/scope_id\[\]=([^&]*)/g) || [];
      scopeValues.forEach((value) => {
        this.$form.find(`input[type=checkbox][value=${value}]`)[0].checked = true;
      })

      let [categoryIdValue] = this._getLocationParams(/filter\[category_id\]=([^&]*)/g) || [];
      this.$form.find(`select#filter_category_id`).first().val(categoryIdValue);

      this.$form.submit();
    }

    /**
     * Handles the logic to update the current location after a form change event.
     * @private
     * @returns {Void} - Returns nothing.
     */
    _onFormChange() {
      let newUrl = '';
      const formAction = this.$form.attr('action');
      const params = this.$form.serialize();

      this.$form.submit();

      if (formAction.indexOf('?') < 0) {
        newUrl = `${formAction}?${params}`;
      } else {
        newUrl = `${formAction}&${params}`;
      }

      exports.history.pushState(null, null, newUrl);
    }
  }

  exports.DecidimMeetings = exports.DecidimMeetings || {};
  exports.DecidimMeetings.MeetingsFormFilterComponent = MeetingsFormFilterComponent;
})(window);
