/* eslint-disable no-div-regex, no-useless-escape, no-param-reassign */
((exports) => {
  class MeetingsFormFilterComponent {
    constructor(selector) {
      this.$form = $(selector);
      this.mounted = false;

      this._onFormChange = this._onFormChange.bind(this);
      this._onPopState = this._onPopState.bind(this);
    }

    unmountComponent() {
      if (this.mounted) {
        this.mounted = false;
        this.$form.off('change', 'input, select', this._onFormChange);

        exports.onpopstate = null;
      }
    }

    mountComponent() {
      if (this.$form.length > 0 && !this.mounted) {
        this.mounted = true;
        this.$form.on('change', 'input, select', this._onFormChange);

        exports.onpopstate = this._onPopState;
      }
    }

    _getLocation() {
      return exports.location;
    }

    _getLocationParams(regex) {
      const location = decodeURIComponent(this._getLocation());
      let values = location.match(regex);
      if (values) {
        values = values.map((val) => val.match(/=(.*)/)[1]);
      }
      return values;
    }

    _clearForm() {
      this.$form.find('input[type=checkbox]').attr('checked', false);
      this.$form.find('input[type=radio]').attr('checked', false);
    }

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
