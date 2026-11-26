import { Controller } from "@hotwired/stimulus"

/**
 * Stimulus controller for the admin import-proposals form.
 *
 * Watches a `<select>` element (the origin component picker) and dynamically
 * fetches the available proposal statuses for the chosen component.
 * The retrieved statuses are rendered as a list of checkboxes inside a
 * container element, so admins can easily filter which proposal statuses to import.
 *
 * Targets:
 *   - `select`    – The `<select>` element used to choose the origin component.
 *   - `container` – The wrapper element where the status checkboxes are rendered.
 *
 * Values:
 *   - `statusesUrl` {String}  – Base URL of the endpoint that returns available statuses.
 *   - `selectedStatuses` {Array} – Pre-selected status tokens (populated on page load
 *     when re-rendering a previously submitted form).
 */
export default class ImportProposalsController extends Controller {

  /**
   * Lifecycle callback invoked by Stimulus when the controller is connected to
   * the DOM. Triggers an initial status fetch based on the currently selected
   * component so that a pre-filled form displays the correct checkboxes.
   * @returns {void}
   */
  connect() {
    this._fetchStatuses(this.selectTarget.value);
  }

  /**
   * Triggered when the select value changes.
   * @param {Event} event - The change event fired by the select element.
   * @returns {void}
   */
  onSelectChange(event) {
    this._fetchStatuses(event.target.value);
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
   * Fetches the available statuses for the given component ID and renders them.
   * @param {string} componentId - The ID of the selected component to fetch statuses for.
   * @returns {void}
   */
  _fetchStatuses(componentId) {
    const container = this.containerTarget;
    if (!componentId) {
      container.innerHTML = "";
      container.style.display = "none";
      return;
    }

    const url = `${this.statusesUrlValue}?origin_id=${componentId}`;
    fetch(url, {
      credentials: "same-origin",
      headers: { Accept: "application/json" }
    }).then((res) => {
      return res.json();
    }).then((statuses) => {
      if (!statuses.length) {
        container.innerHTML = "";
        container.style.display = "none";
        return;
      }

      const selectedStatuses = this.selectedStatusesValue;
      const wrapper = document.createElement("div");
      wrapper.className = "row column";

      statuses.forEach((status) => {
        const div = document.createElement("div");
        const label = document.createElement("label");
        const input = document.createElement("input");
        input.type = "checkbox";
        input.name = "proposals_import[statuses][]";
        input.value = status.token;
        input.checked = selectedStatuses.includes(status.token);
        label.appendChild(input);
        label.appendChild(document.createTextNode(` ${status.title}`));
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
  statusesUrl: String,
  selectedStatuses: { type: Array, default: [] }
}
