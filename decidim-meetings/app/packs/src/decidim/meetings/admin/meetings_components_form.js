import TomSelect from "tom-select/dist/cjs/tom-select.popular";

/**
 * This module manages the Linked Spaces section from the
 * admin meeting edit form.
 *
 * It allows to add and remove components to the meeting and
 * setup a TomSelect for the components selector.
 */

function handleRemoveButton(button) {
  button.addEventListener("click", function(event) {
    button.closest("tr").remove();
  });
}

function handleAddButton() {
  const select = document.querySelector("select[name='add_component_select']");
  const componentId = select.value;
  const componentTitle = select.options[select.selectedIndex].text;

  if (!componentId) {
    return;
  }

  const table = document.querySelector(".js-components");
  const body = document.querySelector(".js-components tbody");
  const template = document.querySelector("#meeting_component_template");
  const clone = template.content.cloneNode(true);
  const title = clone.querySelector(".js-component-title");
  const id = clone.querySelector("input");
  const button = clone.querySelector(".js-remove-component");

  title.textContent = componentTitle;
  id.value = componentId;
  handleRemoveButton(button);

  body.appendChild(clone);

  select.value = "";
  table.classList.remove("hidden");
}

function setupTomSelect() {
  const componentsSelect = document.querySelector(
    "#add_component_select"
  );

  const config = {
    plugins: ["dropdown_input"],
  };

  return new TomSelect(componentsSelect, config);
}

document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll(".js-remove-component").forEach(handleRemoveButton);
  document.querySelector(".js-add-component").addEventListener("click", handleAddButton);

  setupTomSelect();
});
