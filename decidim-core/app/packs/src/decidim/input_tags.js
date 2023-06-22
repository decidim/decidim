/* eslint-disable camelcase */

import TomSelect from "tom-select/dist/cjs/tom-select.popular";

document.addEventListener("DOMContentLoaded", () => {
  const tagContainers = document.querySelectorAll(".js-tags-container");
  const config = {
    plugins: ["remove_button"],
    create: true,
    render: {
      no_results: null
    }
  };

  tagContainers.forEach((container) => new TomSelect(container, config))
});
