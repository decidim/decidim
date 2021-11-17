import AutoComplete from "src/decidim/autocomplete";

$(() => {
  const $autocompleteDiv = $("[data-plugin='autocomplete']");
  if ($autocompleteDiv.length < 1) {
    return;
  }

  $autocompleteDiv.each((_index, element) => {
    AutoComplete.autoConfigure(element);
  })
})
