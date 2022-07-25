const tuggleInfo = (val) => {
  document.querySelectorAll(".help-text").forEach((toBeHidden) => {
    if (val === toBeHidden.id && toBeHidden.style.display === "none") {
      toBeHidden.style.display = null;
    } else {
      toBeHidden.style.display = "none";
    }
  });
};
export default () => {
  const item = document.querySelector("#result_import_projects_origin_component_id");
  item.addEventListener(("change"), (event) => {
    tuggleInfo(`component_${event.target.value}`);
  });
};

