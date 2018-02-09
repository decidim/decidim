// = require typeahead.bundle

$(() => {
  const $mentionContainer = $('.js-mentions-container');

  const sources = [
    "Cayman Islands",
    "Sudan",
    "Macau",
    "Togo",
    "Mali",
    "Morocco",
    "Syria",
    "Puerto Rico",
    "Barbados",
    "Cuba"
  ]

  const bh = new Bloodhound({
    datumTokenizer: Bloodhound.tokenizers.whitespace,
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    local: sources
  });

  function bhRegex(q, sync) {
    // @mention match regex
    const mentionRegex = new RegExp('[@]+[A-Za-z0-9_]+','gim');
    let _matches = mentionRegex.exec(q);
    mentionRegex.test(q) ? bh.search(_matches[0].substring(1), sync) : sync([]);
  }

  $mentionContainer.typeahead({
    minLength: 1, // DEBUG
    highlight: true,
    classNames: {
      input: 'input__mentions',
      menu: 'input__mentions__results',
      hint: 'input__mentions__hint'
    }
  }, {
    source: bhRegex
  });

  $mentionContainer.on('keyup', e => {
    // @ sign
    if (e.altKey && e.keyCode === 50) {
      let me = $(e.target);
      let tmp = me.typeahead('val');
      me.typeahead('open'); // Deletes tag
      me.typeahead('val', tmp);
    }
  });

  $mentionContainer.bind('typeahead:active', function(e) {
    // Prevent typeahead triggers by default
    $mentionContainer.typeahead('close');
  });

});