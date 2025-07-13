/* eslint-disable require-jsdoc */
class DynamicFieldsComponent {
  constructor(options = {}) {
    this.wrapperSelector = options.wrapperSelector;
    this.containerSelector = options.containerSelector;
    this.fieldSelector = options.fieldSelector;
    this.addFieldButtonSelector = options.addFieldButtonSelector;
    this.addSeparatorButtonSelector = options.addSeparatorButtonSelector;
    this.addTitleAndDescriptionButtonSelector = options.addTitleAndDescriptionButtonSelector;
    this.fieldTemplateSelector = options.fieldTemplateSelector;
    this.separatorTemplateSelector = options.separatorTemplateSelector;
    this.TitleAndDescriptionTemplateSelector = options.TitleAndDescriptionTemplateSelector;
    this.removeFieldButtonSelector = options.removeFieldButtonSelector;
    this.moveUpFieldButtonSelector = options.moveUpFieldButtonSelector;
    this.moveDownFieldButtonSelector = options.moveDownFieldButtonSelector;
    this.onAddField = options.onAddField;
    this.onRemoveField = options.onRemoveField;
    this.onMoveUpField = options.onMoveUpField;
    this.onMoveDownField = options.onMoveDownField;
    this.placeholderId = options.placeholderId;
    this.elementCounter = 0;
    this._enableInterpolation();
    this._activateFields();
    this._bindEvents();
  }

  _enableInterpolation() {
    $.fn.replaceAttribute = function(attribute, placeholder, value) {
      $(this).find(`[${attribute}*=${placeholder}]`).addBack(`[${attribute}*=${placeholder}]`).each((index, element) => {
        $(element).attr(attribute, $(element).attr(attribute).replace(placeholder, value));
      });

      return this;
    }

    $.fn.template = function(placeholder, value) {
      // Clean up the template HTML to ensure it only contains elements.
      const $template = $(this).filter((_idx, el) => el.nodeType === Node.ELEMENT_NODE);

      // See the comment below in the `_addField()` method regarding the
      // `<template>` tag support in IE11.
      const $subtemplate = $template.find("template, .decidim-template");

      if ($subtemplate.length > 0) {
        $subtemplate.html((index, oldHtml) => $(oldHtml).template(placeholder, value)[0].outerHTML);
      }

      // Handle those subtemplates that are mapped with the `data-template`
      // attribute. This is also because of the IE11 support.
      const $subtemplateParents = $template.find("[data-template]");

      if ($subtemplateParents.length > 0) {
        $subtemplateParents.each((_i, elem) => {
          const $self = $(elem);
          const $tpl = $($self.data("template"));

          // Duplicate the sub-template with a unique ID as there may be
          // multiple parent templates referring to the same sub-template.
          const $subtpl = $($tpl[0].outerHTML);
          const subtemplateId = `${$tpl.attr("id")}-${value}`;
          const subtemplateSelector = `#${subtemplateId}`;
          $subtpl.attr("id", subtemplateId);
          $self.attr("data-template", subtemplateSelector).data("template", subtemplateSelector);
          $tpl.after($subtpl);

          $subtpl.html((index, oldHtml) => $(oldHtml).template(placeholder, value)[0].outerHTML);
        });
      }

      $template.replaceAttribute("id", placeholder, value);
      $template.replaceAttribute("name", placeholder, value);
      $template.replaceAttribute("data-tabs-content", placeholder, value);
      $template.replaceAttribute("for", placeholder, value);
      $template.replaceAttribute("tabs_id", placeholder, value);
      $template.replaceAttribute("href", placeholder, value);
      $template.replaceAttribute("value", placeholder, value);

      return $template;
    }
  }

  _bindEvents() {
    $(this.wrapperSelector).on("click", this.addFieldButtonSelector, (event) =>
      this._bindSafeEvent(event, () => this._addField(this.fieldTemplateSelector))
    );

    if (this.addSeparatorButtonSelector) {
      $(this.wrapperSelector).on("click", this.addSeparatorButtonSelector, (event) =>
        this._bindSafeEvent(event, () => this._addField(this.separatorTemplateSelector))
      );
    }

    if (this.addTitleAndDescriptionButtonSelector) {
      $(this.wrapperSelector).on("click", this.addTitleAndDescriptionButtonSelector, (event) =>
        this._bindSafeEvent(event, () => this._addField(this.TitleAndDescriptionTemplateSelector))
      );
    }

    $(this.wrapperSelector).on("click", this.removeFieldButtonSelector, (event) =>
      this._bindSafeEvent(event, (target) => this._removeField(target))
    );

    if (this.moveUpFieldButtonSelector) {
      $(this.wrapperSelector).on("click", this.moveUpFieldButtonSelector, (event) =>
        this._bindSafeEvent(event, (target) => this._moveUpField(target))
      );
    }

    if (this.moveDownFieldButtonSelector) {
      $(this.wrapperSelector).on("click", this.moveDownFieldButtonSelector, (event) =>
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

  // Adds a field.
  //
  // template - A String matching the type of the template. Expected to be
  //  either ".decidim-question-template" or ".decidim-separator-template".
  _addField(templateClass = ".decidim-template") {
    const $wrapper = $(this.wrapperSelector);
    const $container = $wrapper.find(this.containerSelector);

    // Allow defining the template using a `data-template` attribute on the
    // wrapper element. This is to allow child templates which would otherwise
    // be impossible using `<script type="text/template">`. See the comment
    // below regarding the `<template>` tag and IE11.
    const templateSelector = $wrapper.data("template");
    let $template = null;
    if (templateSelector) {
      $template = $(templateSelector);
    }
    if ($template === null || $template.length < 1) {
      // To preserve IE11 backwards compatibility, the views are using
      // `<script type="text/template">` with a given `class` instead of
      // `<template>`. The `<template> tags are parsed in IE11 along with the
      // DOM which may cause the form elements inside them to break the forms
      // as they are submitted with them.
      $template = $wrapper.children(`template, ${templateClass}`);
    }
    const $newField = $($template.html()).template(this.placeholderId, this._getUID());
    $newField.find("ul.tabs").attr("data-tabs", true);

    const $lastQuestion = $container.find(this.fieldSelector).last()
    if ($lastQuestion.length > 0) {
      $lastQuestion.after($newField);
    } else {
      $newField.appendTo($container);
    }

    // REDESIGN_PENDING: deprecated
    window.initFoundation($newField);

    if (this.onAddField) {
      this.onAddField($newField);
    }
  }

  _removeField(target) {
    const $target = $(target);
    const $removedField = $target.parents(this.fieldSelector);
    const idInput = $removedField.find("input").filter((idx, input) => input.name.match(/id/));

    if (idInput.length > 0) {
      const deletedInput = $removedField.find("input").filter((idx, input) => input.name.match(/delete/));

      if (deletedInput.length > 0) {
        $(deletedInput[0]).val(true);
      }

      $removedField.addClass("hidden");
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
    // Move the `<script type="text/template">` elements to the bottom of the
    // list container so that they will not cause the question moving
    // functionality to break since it assumes that all children elements are
    // the dynamic field list child items.
    const $wrapper = $(this.wrapperSelector);
    const $container = $wrapper.find(this.containerSelector);
    $container.append($container.find("script"));

    $(this.fieldSelector).each((idx, el) => {
      $(el).template(this.placeholderId, this._getUID());

      $(el).find("ul.tabs").attr("data-tabs", true);
    })
  }

  _getUID() {
    this.elementCounter += 1;

    return (new Date().getTime()) + this.elementCounter;
  }
}

export default function createDynamicFields(options) {
  return new DynamicFieldsComponent(options);
}
