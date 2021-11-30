import AutoComplete from "src/decidim/autocomplete";

/**
 * This function can be used to create an autocomplete input automatically
 * from the following kind of div:
 *   <div data-autocomplete="{...}"></div>
 *
 * The data-autocomplete attribute should contain the following configuration
 * as an encoded JSON, which is used to generate the AutoComplete options:
 * - name: assembly_member[user_id],
 * - options: [],
 * - placeholder: "Select a participant",
 * - searchPromptText: "Type at least three characters to search"
 * - noResultsText: "No results found"
 * - searchURL: "http://..."
 * - changeURL: null,
 * - selected: "",
 *
 * @param {HTMLElement} el The element to generate the autocomplete for.
 * @returns {AutoComplete} An instance of the AutoComplete class.
 */
const autoConfigure = (el) => {
  const config = JSON.parse(el.dataset.autocomplete);
  // const input = document.createElement("input");
  // input.name = config.name;
  // input.type = "hidden";

  const textInput = document.createElement("input");
  // input.name = config.name;
  textInput.type = "text";
  textInput.className = "autocomplete-input";

  if (config.placeholder) {
    textInput.placeholder = config.placeholder;
  }
  if (config.selected) {
    // input.value = config.selected.value;
    textInput.value = config.selected.label;
  }
  el.appendChild(textInput);
  // el.insertBefore(input, textInput);

  const dataSource = (query, callback) => {
    const params = new URLSearchParams({ term: query });
    fetch(`${config.searchURL}?${params.toString()}`, {
      method: "GET",
      headers: { "Content-Type": "application/json" }
    }).then((response) => response.json()).then((data) => {
      console.log("data", data)
      callback(data)
    });
  };

  const ac = new AutoComplete(textInput, {
    name: config.name,
    mode: "sticky",
    dataMatchKeys: ["label"],
    dataSource
  });
  el.addEventListener("selection", ac);

  return ac;
}

$(() => {
  const $autocompleteDiv = $("[data-plugin='autocomplete']");
  if ($autocompleteDiv.length < 1) {
    return;
  }

  $autocompleteDiv.each((_index, element) => {
    autoConfigure(element);
  })

  // Stop input field from bubbling open and close events to parent elements,
  // because foundation closes modal from these events.
  $("#autocomplete").on("open close", (event) => {
    event.stopPropagation();
  })
})
