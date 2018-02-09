

$(() => {
  const $mentionContainer = $('.js-mentions-container');

  // TEMP DATA TESTING
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

  $mentionContainer.mentionsInput({
    suffix: ' ',
    source: sources
  });

  $mentionContainer.on("autocompletesearch", function(event, ui) {
    console.log(event, ui);
  });

});