import { Controller } from "@hotwired/stimulus"

/**
 * Handles the revocation form of a single verification method: reveals the
 * sticky actions bar and keeps the submit button's confirm text in sync with
 * the picked option and the optional "before date" field. Picking an option
 * resets the sibling forms through a `revocations:picked` document event, so
 * only one form is active at a time.
 */
export default class RevocationsController extends Controller {
  connect() {
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

  // Without a date the count of the picked option is already on the radio, so
  // the server is only asked when a date is set.
  refresh() {
    const radio = this._checkedOption();
    if (!radio) {
      return;
    }

    const option = radio.dataset.revocationsOption;
    const requestedDate = this._dateInput()?.value || "";
    if (!requestedDate) {
      this._setConfirm(this._confirmTemplate(option, false), { count: radio.dataset.count });
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

    fetch(`${url}?${params}`, {
      headers: { "Accept": "application/json", "X-Requested-With": "XMLHttpRequest" },
      credentials: "same-origin"
    }).then((response) => response.json()).then((data) => {
      // Discard responses the form has already moved on from (another option
      // picked, another date typed or the form reset by a sibling one).
      if (this._checkedOption() !== radio || (this._dateInput()?.value || "") !== requestedDate) {
        return;
      }

      if (typeof data.count === "undefined") {
        return;
      }

      const date = this._visibleDateInput()?.value || requestedDate;
      this._setConfirm(this._confirmTemplate(option, true), { count: data.count, date });
    }).catch((error) => {
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

    [this._dateInput(), this._visibleDateInput()].forEach((input) => {
      if (input) {
        input.value = "";
      }
    });
  }

  _checkedOption() {
    return this.optionTargets.find((radio) => radio.checked);
  }

  _dateInput() {
    return this.dateContainerTarget.querySelector("input[name='revocations[before_date]']");
  }

  // The text input the datepicker renders in place of the hidden submittable
  // one, holding the date as the user sees it (e.g. dd/mm/yyyy).
  _visibleDateInput() {
    const input = this._dateInput();

    return input && document.getElementById(`${input.id}_date`);
  }

  // The Decidim confirm dialog reads the confirm text from the attribute.
  _setConfirm(template, { count, date = "" }) {
    if (!template) {
      return;
    }

    this.submitTarget.dataset.confirm = template.
      replace(/%\{count\}/g, count).
      replace(/%\{date\}/g, date);
  }

  _confirmTemplate(option, withDate) {
    const templates = this.submitTarget.dataset;

    if (option === "impersonated") {
      return withDate
        ? templates.confirmImpersonatedBeforeDate
        : templates.confirmImpersonated;
    }

    return withDate
      ? templates.confirmTotalBeforeDate
      : templates.confirmTotal;
  }
}

RevocationsController.targets = ["option", "name", "dateContainer", "bar", "submit"]
RevocationsController.values = { countUrl: String }
