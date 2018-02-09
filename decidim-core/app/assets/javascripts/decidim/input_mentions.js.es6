// = require tribute

$(() => {
  const $mentionContainer = $('.js-mentions-container');

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

  let tribute = new Tribute({
    values: sources,
    positionMenu: false,
    menuContainer: $mentionContainer.parent()[0],
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

});