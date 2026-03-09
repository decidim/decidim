import { Controller } from "@hotwired/stimulus"

/**
 * ImportProposals Stimulus Controller
 *
 * Handles the dynamic loading of proposal states when the origin component
 * is selected in the proposals import form. When a component is chosen, it
 * fetches the available states via JSON and renders them as checkboxes.
 *
 * Required HTML structure:
 * - A wrapper element with `data-controller="import-proposals"`
 * - A `<select>` inside with `data-import-proposals-target="select"` and
 *   `data-import-proposals-states-url-value` pointing to the states endpoint
 * - A container element with `data-import-proposals-target="container"` and
 *   optionally `data-import-proposals-selected-states-value` (JSON array)
 *
 * @extends Controller
 */
export default class ImportProposalsController extends Controller {
  static targets = ["select", "container"]

  static values = {
    statesUrl: String,
    selectedStates: { type: Array, default: [] }
  }

  connect() {
    this._fetchStates(this.selectTarget.value);
  }

  /**
   * Triggered when the select value changes.
   * @param {Event} event
   * @returns {void}
   */
  onSelectChange(event) {
    this._fetchStates(event.target.value);
  }

  /**
   * Escapes a string for safe insertion into HTML.
   * @param {string} str
   * @returns {string}
   */
  _escapeHtml(str) {
    const div = document.createElement("div");
    div.appendChild(document.createTextNode(str));
    return div.innerHTML;
  }

  /**
   * Fetches the available states for the given component ID and renders them.
   * @param {string} componentId
   * @returns {void}
   */
  _fetchStates(componentId) {
    const container = this.containerTarget;

    if (!componentId) {
      container.innerHTML = "";
      container.style.display = "none";
      return;
    }

    const url = `${this.statesUrlValue}?origin_id=${componentId}`;

    fetch(url, {
      credentials: "same-origin",
      headers: { Accept: "application/json" }
    }).then((res) => {
      return res.json();
    }).then((states) => {
      if (!states.length) {
        container.innerHTML = "";
        container.style.display = "none";
        return;
      }

      const selectedStates = this.selectedStatesValue;
      const wrapper = document.createElement("div");
      wrapper.className = "row column";

      states.forEach((state) => {
        const div = document.createElement("div");
        const label = document.createElement("label");
        const input = document.createElement("input");

        input.type = "checkbox";
        input.name = "proposals_import[states][]";
        input.value = state.token;
        input.checked = selectedStates.includes(state.token);

        label.appendChild(input);
        label.appendChild(document.createTextNode(` ${state.title}`));
        div.appendChild(label);
        wrapper.appendChild(div);
      });

      container.innerHTML = "";
      container.appendChild(wrapper);
      container.style.display = "block";
    }).catch(() => {
      container.innerHTML = "";
      container.style.display = "none";
    });
  }
}
