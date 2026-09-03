import { Controller } from "@hotwired/stimulus"

/**
 * Handles the revocation form of a single verification method: reveals the
 * sticky actions bar and keeps the submit button's confirm text in sync with
 * the picked option and the optional "before date" field. Picking an option
 * resets the sibling forms through a `revocations:picked` document event, so
 * only one form is active at a time.
 */
export default class extends Controller {
  static get targets() {
    return ["option", "name", "date", "dateContainer", "bar", "submit"];
  }

  static get values() {
    return { countUrl: String };
  }

  connect() {
    this.fallbackConfirm = this.submitTarget.dataset.confirm;
    this.onSiblingPicked = this.onSiblingPicked.bind(this);
    document.addEventListener("revocations:picked", this.onSiblingPicked);
    this.reset();
  }

  disconnect() {
    document.removeEventListener("revocations:picked", this.onSiblingPicked);
  }

  pick() {
    this.dispatch("picked");
    this.barTarget.classList.remove("hidden");
    this.refresh();
  }

  // The picked option already carries its dateless message; the server is
  // asked only when a date is set.
  refresh() {
    const radio = this._checkedOption();
    if (!radio) {
      return;
    }

    const requestedDate = this.dateTarget.value;
    if (!requestedDate) {
      this.submitTarget.disabled = false;
      this._setConfirm(radio.dataset.confirmMessage);
      return;
    }

    const url = this.countUrlValue;
    const name = this.nameTarget.value;
    if (!url || !name) {
      return;
    }

    const params = new URLSearchParams();
    params.set("revocations[name]", name);
    params.set("revocations[impersonated_only]", radio.value);
    params.set("revocations[before_date]", requestedDate);

    // Hold the submission behind the generic confirm text until the accurate
    // message arrives.
    this.submitTarget.dataset.confirm = this.fallbackConfirm;
    this.submitTarget.disabled = true;

    fetch(`${url}?${params}`, {
      headers: { "Accept": "application/json", "X-Requested-With": "XMLHttpRequest" },
      credentials: "same-origin"
    }).then((response) => {
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }
      return response.json();
    }).then((data) => {
      // Discard responses the form has already moved on from.
      if (this._checkedOption() !== radio || this.dateTarget.value !== requestedDate) {
        return;
      }

      this.submitTarget.disabled = false;
      this._setConfirm(data.message);
    }).catch((error) => {
      this.submitTarget.disabled = false;
      console.error("Error fetching authorizations count:", error);
    });
  }

  onSiblingPicked(event) {
    if (event.target === this.element) {
      return;
    }

    this.reset();
  }

  reset() {
    this.optionTargets.forEach((radio) => {
      radio.checked = false;
    });

    this.barTarget.classList.add("hidden");
    this.submitTarget.disabled = false;
    this.submitTarget.dataset.confirm = this.fallbackConfirm;

    this.dateTarget.value = "";
    const visibleDate = this._visibleDateInput();
    if (visibleDate) {
      visibleDate.value = "";
    }
  }

  _checkedOption() {
    return this.optionTargets.find((radio) => radio.checked);
  }

  // The datepicker's visible text input, holding the date as the user sees it.
  _visibleDateInput() {
    return document.getElementById(`${this.dateTarget.id}_date`);
  }

  // The Decidim confirm dialog reads the confirm text from the attribute.
  _setConfirm(message) {
    if (!message) {
      return;
    }

    this.submitTarget.dataset.confirm = message;
  }
}
