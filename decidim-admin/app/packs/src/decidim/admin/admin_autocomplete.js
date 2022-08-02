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
 * - searchURL: "http://..."
 * - selected: "",
 *
 * @param {HTMLElement} el The element to generate the autocomplete for.
 * @returns {AutoComplete} An instance of the AutoComplete class.
 */
const autoConfigure = (el) => {
  const config = JSON.parse(el.dataset.autocomplete);
  const searchUrl = new URL(config.searchURL);
  const textInput = document.createElement("input");
  textInput.type = "text";
  textInput.className = "autocomplete-input";
  el.appendChild(textInput);
  let mode = config.mode || "sticky"
  let selected = null;
  if (config.selected) {
    switch (mode) {
    case "multi":
      selected = config.selected.map((item) => (
        {
          key: "label",
          value: {
            value: item.value,
            label: item.label
          }
        }
      ));
      break;
    case "sticky":
      selected = { key: "label", value: config.options[config.options.length - 1] };
      break;
    default:
      selected = config.selected;
    }
  }

  const dataSource = (query, callback) => {
    const params = new URLSearchParams({
      ...Object.fromEntries(searchUrl.searchParams),
      term: query
    });
    fetch(`${searchUrl.origin}${searchUrl.pathname}?${params.toString()}`, {
      method: "GET",
      headers: { "Content-Type": "application/json" }
    }).then((response) => response.json()).then((data) => {
      callback(data)
    });
  };

  const ac = new AutoComplete(textInput, {
    name: config.name,
    placeholder: config.placeholder,
    selected: selected,
    mode: mode,
    searchPrompt: true,
    searchPromptText: config.searchPromptText,
    threshold: 3,
    dataMatchKeys: ["label"],
    dataSource
  });

  return ac;
}

$(() => {
  const $autocompleteDiv = $("[data-autocomplete]");
  if ($autocompleteDiv.length < 1) {
    return;
  }

  $autocompleteDiv.each((_index, element) => {
    autoConfigure(element);
  })
})
