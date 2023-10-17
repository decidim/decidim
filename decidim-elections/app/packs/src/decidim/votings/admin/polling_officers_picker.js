import TomSelect from "tom-select/dist/cjs/tom-select.popular";

document.addEventListener("DOMContentLoaded", () => {
  const tagContainers = document.querySelectorAll("#polling_officers_filter");
  tagContainers.forEach((container) => {
    const { tmName, tmItems, tmNoResults } = container.dataset
    const config = {
      plugins: ["remove_button", "dropdown_input"],
      allowEmptyOption: true,
      items: JSON.parse(tmItems),
      render: {
        item: (data, escape) => `<div>${escape(data.text)}<input type="hidden" name="${tmName}[]" value="${data.value}" /></div>`,
        // eslint-disable-next-line camelcase
        ...(tmNoResults && { no_results: () => `<div class="no-results">${tmNoResults}</div>` })
      }
    };

    return new TomSelect(container, config)
  })
});
