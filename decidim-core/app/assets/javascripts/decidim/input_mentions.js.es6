// = require tribute

$(() => {
  const $mentionContainer = $('.js-mentions');
  const nodatafound = 'No results.'; // TODO: this string must be i18n
  const sources = []; // TODO: Object with remote data. See Tribute.js DOCS

  // EXAMPLE DATA
  // tag & name properties are mandatory
  //
  // source = [{
  //     "tag": "barrera",
  //     "name": "Collins Franklin",
  //   },
  //   {
  //     "tag": "woods",
  //     "name": "Nadine Buck",
  //   },
  //   ...]

  // tribute.js docs - http://github.com/zurb/tribute
  let tribute = new Tribute({
    values: sources,
    positionMenu: false,
    menuContainer: null,
    fillAttr: 'tag',
    noMatchTemplate: () => '<li>' + nodatafound + '</li>',
    lookup: (item) => item.tag + item.name,
    selectTemplate: function(item) {
      if (typeof item === 'undefined') return null;
      if (this.range.isContentEditable(this.current.element)) {
        return '<span contenteditable="false">' + '@' + item.original.tag + '</span>';
      }
      return '@' + item.original.tag;
    },
    menuItemTemplate: function(item) {
      let tpl = '<strong>' + item.original.tag + '</strong>&nbsp;<small>' + item.original.name + '</small>';
      return tpl;
    },
  });

  tribute.attach($mentionContainer);

  // DOM manipulation
  $mentionContainer.on('focusin', e => {
    // Set the parent container relative to the current element
    tribute.menuContainer = e.target.parentNode;
  });
  $mentionContainer.on('focusout', e => {
    let $parent = $(e.target).parent();

    if ($parent.hasClass('is-active')) {
      $parent.removeClass('is-active');
    }
  });
  $mentionContainer.on('input', e => {
    let $parent = $(e.target).parent();

    if (tribute.isActive) {
      // We need to move the container to the wrapper selected
      let $tribute = $('.tribute-container');
      $tribute.appendTo($parent);
      // Remove the inline styles, relative to absolute positioning
      $tribute.removeAttr('style');
      // Parent adaptation
      $parent.addClass('is-active');
    } else {
      $parent.removeClass('is-active');
    }
  });

});