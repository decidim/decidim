((exports) => {
  class DynamicFieldsComponent {
    constructor(options = {}) {
      this.templateId = options.templateId;
      this.wrapperSelector = options.wrapperSelector;
      this.containerSelector = options.containerSelector;
      this.fieldSelector = options.fieldSelector;
      this.addFieldButtonSelector = options.addFieldButtonSelector;
      this.removeFieldButtonSelector = options.removeFieldButtonSelector;
      this.onAddField = options.onAddField;
      this.onRemoveField = options.onRemoveField;
      this.tabsPrefix = options.tabsPrefix;
      this._compileTemplate();
      this._bindEvents();
    }

    _compileTemplate() {
      $.template(this.templateId, $(`#${this.templateId}`).html());
    }

    _bindEvents() {
      $(this.wrapperSelector).on('click', this.addFieldButtonSelector, (event) =>
        this._bindSafeEvent(event, () => this._addField())
      );

      $(this.wrapperSelector).on('click', this.removeFieldButtonSelector, (event) =>
        this._bindSafeEvent(event, (target) => this._removeField(target))
      );
    }

    _bindSafeEvent(event, cb) {
      event.preventDefault();
      event.stopPropagation();

      try {
        return cb(event.target);
      } catch (error) {
        console.error(error); // eslint-disable-line no-console
        return error;
      }
    }

    _addField() {
      const $container = $(this.wrapperSelector).find(this.containerSelector);
      const position = $container.children().length;

      const tabsId = `${this.tabsPrefix}-${this._getUID()}`;

      const $newField = $.tmpl(this.templateId, {
        position,
        questionLabelPosition: position + 1,
        tabsId
      });

      $newField.find('[disabled]').attr('disabled', false);
      $newField.find('ul.tabs').attr('data-tabs', true);

      $newField.appendTo($container);
      $newField.foundation();

      if (this.onAddField) {
        this.onAddField($newField);
      }
    }

    _removeField(target) {
      const $target = $(target);
      const $removedField = $target.parents(this.fieldSelector);
      const idInput = $removedField.find('input').filter((idx, input) => input.name.match(/id/));

      if (idInput.length > 0) {
        const deletedInput = $removedField.find('input').filter((idx, input) => input.name.match(/delete/));

        if (deletedInput.length > 0) {
          $(deletedInput[0]).val(true);
        }

        $removedField.addClass('hidden');
        $removedField.hide();
      } else {
        $removedField.remove();
      }

      if (this.onRemoveField) {
        this.onRemoveField($removedField);
      }
    }

    _getUID() {
      return `${new Date().getTime()}-${Math.floor(Math.random() * 1000000)}`;
    }
  }

  exports.DecidimAdmin = exports.DecidimAdmin || {};
  exports.DecidimAdmin.DynamicFieldsComponent = DynamicFieldsComponent;
  exports.DecidimAdmin.createDynamicFields = (options) => {
    return new DynamicFieldsComponent(options);
  };
})(window);
