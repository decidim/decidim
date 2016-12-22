((exports) => {
  class MeetingsFormFilterComponent {
    constructor(selector) {
      this.$form = $(selector);
      this.mounted = false;
    }

    getLocationParams(regex) {
      const location = decodeURIComponent(exports.location);
      let values = location.match(regex);
      if (values) {
        values = values.map(val => val.match(/=(.*)/)[1]);
      }
      return values;
    }

    clearForm() {
      this.$form.find('input[type=checkbox]').attr('checked', false);
      this.$form.find('input[type=radio]').attr('checked', false);
    }

    onPopState(event) {
      this.clearForm();

      let [sortValue] = this.getLocationParams(/order_start_time=([^&]*)/g) || ["asc"];
      this.$form.find(`input[type=radio][value=${sortValue}]`)[0].checked = true;

      let scopeValues = this.getLocationParams(/scope_id\[\]=([^&]*)/g) || [];
      scopeValues.forEach(value => {
        this.$form.find(`input[type=checkbox][value=${value}]`)[0].checked = true;
      })

      let [categoryIdValue] = this.getLocationParams(/filter\[category_id\]=([^&]*)/g) || [];
      this.$form.find(`select#filter_category_id`).first().val(categoryIdValue);

      this.$form.submit();
    }

    onFormChange() {
      let newUrl;
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

    unmountComponent() {
      if (this.mounted) {
        console.log("unmount")
        this.mounted = false;
        this.$form.off('change', 'input, select', () => {
          this.onFormChange();
        });

        exports.onpopstate = null;
      }
    }

    mountComponent() {
      if (this.$form.length > 0 && !this.mounted) {
        console.log("mount")
        this.mounted = true;
        this.$form.on('change', 'input, select', () => {
          this.onFormChange();
        });

        exports.onpopstate = (event) => this.onPopState(event);
      }
    }
  }

  exports.DecidimMeetings = exports.DecidimMeetings || {};
  exports.DecidimMeetings.MeetingsFormFilterComponent = MeetingsFormFilterComponent;
})(window);
