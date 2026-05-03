import { Controller } from "@hotwired/stimulus"

/**
 * Stimulus controller for the admin import-proposals form.
 *
 * Watches a `<select>` element (the origin component picker) and dynamically
 * fetches the available proposal states for the chosen component.
 * The retrieved states are rendered as a list of checkboxes inside a
 * container element, so admins can easily filter which proposal states to import.
 *
 * Targets:
 *   - `select`    – The `<select>` element used to choose the origin component.
 *   - `container` – The wrapper element where the state checkboxes are rendered.
 *
 * Values:
 *   - `statesUrl` {String}  – Base URL of the endpoint that returns available states.
 *   - `selectedStates` {Array} – Pre-selected state tokens (populated on page load
 *     when re-rendering a previously submitted form).
 */
export default class ImportProposalsController extends Controller {

  /**
   * Lifecycle callback invoked by Stimulus when the controller is connected to
   * the DOM. Triggers an initial state fetch based on the currently selected
   * component so that a pre-filled form displays the correct checkboxes.
   * @returns {void}
   */
  connect() {
    this._fetchStates(this.selectTarget.value);
  }

  /**
   * Triggered when the select value changes.
   * @param {Event} event - The change event fired by the select element.
   * @returns {void}
   */
  onSelectChange(event) {
    this._fetchStates(event.target.value);
  }

  /**
   * Escapes a string for safe insertion into HTML.
   * @param {string} str - The string to escape.
   * @returns {string} The escaped HTML string.
   */
  _escapeHtml(str) {
    const div = document.createElement("div");
    div.appendChild(document.createTextNode(str));
    return div.innerHTML;
  }

  /**
   * Fetches the available states for the given component ID and renders them.
   * @param {string} componentId - The ID of the selected component to fetch states for.
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

ImportProposalsController.targets = ["select", "container"]
ImportProposalsController.values = {
  statesUrl: String,
  selectedStates: { type: Array, default: [] }
}
