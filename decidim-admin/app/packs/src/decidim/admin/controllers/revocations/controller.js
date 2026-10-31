import { Controller } from "@hotwired/stimulus"

/**
 * Handles the revocation form of a single verification method. Picking an
 * option resets the sibling forms through a `revocations:picked` document
 * event, so only one form is active at a time.
 */
export default class extends Controller {
  static get targets() {
    return ["option", "name", "date", "dateContainer", "bar", "submit", "count", "total", "period", "callout"];
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

  /**
   * Syncs the form with the picked option and the date. The option carries
   * its dateless messages, so the server is asked only when a date is set.
   * @returns {void}
   */
  refresh() {
    const radio = this._checkedOption();
    if (!radio) {
      return;
    }

    const requestedDate = this.dateTarget.value;
    // The datepicker empties the submittable date while the visible one is
    // incomplete, which must not read as "no date".
    if (!requestedDate && this._visibleDateInput()?.value) {
      this._holdSubmission();
      return;
    }

    if (!requestedDate) {
      this.submitTarget.disabled = false;
      this._setConfirm(radio.dataset.confirmMessage);
      this._showCounts();
      this._showCallout("info", radio.dataset.calloutMessage);
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

    // Hold the submission until the accurate message arrives.
    this._holdSubmission();

    fetch(`${url}?${params}`, {
      headers: { "Accept": "application/json", "X-Requested-With": "XMLHttpRequest" },
      credentials: "same-origin"
    }).then((response) => {
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }
      return response.json();
    }).then((data) => {
      if (this._isOutdated(radio, requestedDate)) {
        return;
      }

      this.submitTarget.disabled = data.counts[radio.dataset.revocationsOption] === 0;
      this._setConfirm(data.message);
      this._showCounts(data.counts, data.period);
      this._showCallout(data.callout.level, data.callout.message);
    }).catch((error) => {
      console.error("Error fetching authorizations count:", error);
      if (!this._isOutdated(radio, requestedDate)) {
        this.submitTarget.disabled = false;
      }
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
    this._showCounts();
    this._showCallout();

    this.dateTarget.value = "";
    const visibleDate = this._visibleDateInput();
    if (visibleDate) {
      visibleDate.value = "";
    }
  }

  _checkedOption() {
    return this.optionTargets.find((radio) => radio.checked);
  }

  _holdSubmission() {
    this.submitTarget.dataset.confirm = this.fallbackConfirm;
    this.submitTarget.disabled = true;
    this._showCounts();
    this._showCallout();
  }

  _isOutdated(radio, requestedDate) {
    return this._checkedOption() !== radio || this.dateTarget.value !== requestedDate;
  }

  /**
   * Finds the datepicker's visible text input, holding the date as the user sees it.
   * @returns {HTMLInputElement|null} The visible date input
   */
  _visibleDateInput() {
    return document.getElementById(`${this.dateTarget.id}_date`);
  }

  _showCounts(counts = null, period = "") {
    this.countTargets.forEach((element) => {
      element.textContent = counts
        ? counts[element.dataset.option]
        : element.dataset.total;
    });
    this.totalTargets.forEach((element) => element.classList.toggle("hidden", !counts));
    this.periodTargets.forEach((element) => {
      element.textContent = counts
        ? period
        : "";
      element.classList.toggle("hidden", !counts);
    });
  }

  _showCallout(level = null, message = null) {
    this.calloutTargets.forEach((callout) => {
      const visible = Boolean(message) && callout.dataset.level === level;
      if (visible) {
        callout.querySelector(".flash__message").textContent = message;
      }
      callout.classList.toggle("hidden", !visible);
    });
  }

  /**
   * Sets the confirm text, which the Decidim confirm dialog reads from the attribute.
   * @param {string} message - The confirm text
   * @returns {void}
   */
  _setConfirm(message) {
    if (!message) {
      return;
    }

    this.submitTarget.dataset.confirm = message;
  }
}
