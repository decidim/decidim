const toggleInfo = (val) => {
  document.querySelectorAll(".help-text").forEach((toBeHidden) => {
    if (val === toBeHidden.id && toBeHidden.classList.value.includes("hide")) {
      toBeHidden.classList.remove("hide")
    } else {
      toBeHidden.classList.add("hide")
    }
  });
};
export default () => {
  const item = document.querySelector("#result_import_projects_origin_component_id");
  item.addEventListener(("change"), (event) => {
    toggleInfo(`component_${event.target.value}`);
  });
};
