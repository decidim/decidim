// = require tribute

$(() => {
  const $mentionContainer = $('.js-mentions');

  // TEMP DATA TESTING
  const sources = [{
      "tag": "barrera",
      "name": "Collins Franklin",
      "img": "http://placehold.it/32x32"
    },
    {
      "tag": "woods",
      "name": "Nadine Buck",
      "img": "http://placehold.it/32x32"
    },
    {
      "tag": "harding",
      "name": "Edna Taylor",
      "img": "http://placehold.it/32x32"
    },
    {
      "tag": "brennan",
      "name": "Myrtle Coleman",
      "img": "http://placehold.it/32x32"
    },
    {
      "tag": "rutledge",
      "name": "Priscilla Donovan",
      "img": "http://placehold.it/32x32"
    }
  ];

  // tribute.js - http://github.com/zurb/tribute
  let tribute = new Tribute({
    values: sources,
    positionMenu: false,
    // menuContainer: document.activeElement.parentNode,
    fillAttr: 'tag',
    noMatchTemplate: null,
    lookup: function(item) {
      return item.tag + item.name;
    },
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
    tribute.menuContainer = e.target.parentNode
  });
  $mentionContainer.on('focusout', e => {
    let $parent = $(e.target).parent();
    // REVIEW no funciona del todo
    if (e.target.parentNode !== tribute.menuContainer) {
      tribute.menuContainer = null;
    }
    if ($parent.hasClass('is-active')) {
      $parent.removeClass('is-active');
    }
  });
  $mentionContainer.on('input', e => {
    let $parent = $(e.target).parent();

    if (tribute.isActive) {
      let $me = $(e.target).next();
      $me.removeAttr('style');
      $parent.addClass('is-active');
    } else {
      $parent.removeClass('is-active');
    }
  });

});