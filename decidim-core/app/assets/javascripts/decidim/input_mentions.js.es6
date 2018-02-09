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
    // maybe you pull out a certain substring from `q` before passing
    // it to #search
    charRegex.test(q) ? bh.search(q, sync) : sync([]);
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

      // set previous text
      // $(e.target).val(e.target.value);
    }
  });

  $mentionContainer.bind('typeahead:active', function(e) {
    // Prevent typeahead triggers by default
    $mentionContainer.typeahead('close');
  });

});