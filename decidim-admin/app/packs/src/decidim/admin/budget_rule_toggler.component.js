/**
 * BudgetRuleTogglerComponent
 *
 * Handles showing and hiding rule-specific input containers
 * based on the selected radio option.
 */
export default class BudgetRuleTogglerComponent {
  /**
   * @param {Object} options
   * @param {HTMLInputElement[]} options.ruleRadios - Array of radio inputs controlling the rules
   * @param {Record<string, string[]>} options.mapping - Mapping from radio values to selectors of containers to show
   */
  constructor(options = {}) {
    this.ruleRadios = options.ruleRadios;
    this.mapping = options.mapping || {};
    this._bindEvents();
    this._runInitial();
  }

  /**
   * Bind change events on all radios
   * @private
   */
  _bindEvents() {
    this.ruleRadios.forEach((radio) => {
      radio.addEventListener("change", (event) => {
        this._run(event.target);
      });
    });
  }

  /**
   * Run toggler logic on page load
   * @private
   */
  _runInitial() {
    const checked = this.ruleRadios.find((radio) => radio.checked);
    if (checked) {
      this._run(checked);
    } else {
      this._hideAll();
    }
  }

  /**
   * Show the containers associated with the selected radio
   * @param {HTMLInputElement} target - The radio input that triggered the change
   * @private
   */
  _run(target) {
    this._hideAll();

    const value = target.value;
    const selectors = this.mapping[value] || [];

    selectors.forEach((selector) => this._show(selector));
  }

  /**
   * Hide all containers referenced in the mapping
   * @private
   */
  _hideAll() {
    const allSelectors = Object.values(this.mapping).flat();
    allSelectors.forEach((selector) => {
      const el = document.querySelector(selector);
      if (el) el.style.display = "none";
    });
  }

  /**
   * Show a container by selector
   * @param {string} selector - CSS selector of the container to show
   * @private
   */
  _show(selector) {
    const el = document.querySelector(selector);
    if (el) el.style.display = "";
  }
}
