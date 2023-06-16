import TomSelect from "tom-select/dist/cjs/tom-select";

document.addEventListener("DOMContentLoaded", () => {
  const tagContainers = document.querySelectorAll(".js-tags-container");
  const config = {
    create: true,
  };

  tagContainers.forEach(container => new TomSelect(container, config))
});
