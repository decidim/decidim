((exports) => {
  class DynamicFieldsComponent {
    constructor(options = {}) {
      this.templateId = options.templateId;
      this.wrapperSelector = options.wrapperSelector;
      this.containerSelector = options.containerSelector;
      this.fieldSelector = options.fieldSelector;
      this.addFieldButtonSelector = options.addFieldButtonSelector;
      this.removeFieldButtonSelector = options.removeFieldButtonSelector;
      this.moveUpFieldButtonSelector = options.moveUpFieldButtonSelector;
      this.moveDownFieldButtonSelector = options.moveDownFieldButtonSelector;
      this.onAddField = options.onAddField;
      this.onRemoveField = options.onRemoveField;
      this.onMoveUpField = options.onMoveUpField;
      this.onMoveDownField = options.onMoveDownField;
      this.tabsPrefix = options.tabsPrefix;
      this._enableInterpolation();
      this._activateFields();
      this._bindEvents();
    }

    _enableInterpolation() {
      $.fn.template = function(placeholder, value) {
        return $(this).html((id, oldHtml) => oldHtml.replace(new RegExp(placeholder, "g"), value));
      }
    }

    _bindEvents() {
      $(this.wrapperSelector).on('click', this.addFieldButtonSelector, (event) =>
        this._bindSafeEvent(event, () => this._addField())
      );

      $(this.wrapperSelector).on('click', this.removeFieldButtonSelector, (event) =>
        this._bindSafeEvent(event, (target) => this._removeField(target))
      );

      if (this.moveUpFieldButtonSelector) {
        $(this.wrapperSelector).on('click', this.moveUpFieldButtonSelector, (event) =>
          this._bindSafeEvent(event, (target) => this._moveUpField(target))
        );
      }

      if (this.moveDownFieldButtonSelector) {
        $(this.wrapperSelector).on('click', this.moveDownFieldButtonSelector, (event) =>
          this._bindSafeEvent(event, (target) => this._moveDownField(target))
        );
      }
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
      const $newField = $($(`#${this.templateId}`).html()).template(this._getPlaceholderTabId(), this._getUniqueTabId());

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

    _moveUpField(target) {
      const $target = $(target);
      const $movedUpField = $target.parents(this.fieldSelector);

      $movedUpField.prev().before($movedUpField);

      if (this.onMoveUpField) {
        this.onMoveUpField($movedUpField);
      }
    }

    _moveDownField(target) {
      const $target = $(target);
      const $movedDownField = $target.parents(this.fieldSelector);

      $movedDownField.next().after($movedDownField);

      if (this.onMoveDownField) {
        this.onMoveDownField($movedDownField);
      }
    }

    _activateFields() {
      $(this.fieldSelector).each((idx, el) => {
        $(el).template(this._getPlaceholderTabId(), this._getUniqueTabId());

        $(el).find('ul.tabs').attr('data-tabs', true);
      })
    }

    _getPlaceholderTabId() {
      return `${this.tabsPrefix}-id`;
    }

    _getUniqueTabId() {
      return `${this.tabsPrefix}-${this._getUID()}`;
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
