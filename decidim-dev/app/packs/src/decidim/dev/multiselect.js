import AutoComplete from "src/decidim/autocomplete"

$(() => {
  document.querySelector("body").innerHTML += "<h1>TESTI</h1>";
  const el = document.querySelector("input.test-multiselect")
  if (!el) {
    return;
  }

  const autoComplete = new AutoComplete(el, {
    name: "recipient_id[]",
    mode: el.dataset.mode,
    dataMatchKeys: ["label"],
    dataSource: (query, callback) => {
      callback([
        {value: 1, label: "supertagi" },
        {value: 2, label: "normitagi" },
        {value: 3, label: "jokutagi" },
        {value: 4, label: "leverage" }
      ]);
    }
  });
  el.addEventListener("selection", autoComplete);
})
