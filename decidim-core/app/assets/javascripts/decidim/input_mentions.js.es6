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

  var states = new Bloodhound({
    datumTokenizer: Bloodhound.tokenizers.whitespace,
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    local: sources
  });

  $mentionContainer.on('keyup', function(e) {

    if (e.keyCode === 50) {

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
      source: states
    });

  });



});