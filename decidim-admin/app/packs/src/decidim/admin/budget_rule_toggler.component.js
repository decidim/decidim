/**
 * BudgetRuleTogglerComponent
 *
 * Handles showing and hiding rule-specific input containers
 * based on the selected radio option.
 */
export default class BudgetRuleTogglerComponent {

  /**
   * Constructor of BudgetRuleTogglerComponent class.
   *
   * @param {Object} options - Configuration options
   * @param {HTMLInputElement[]} options.ruleRadios - Array of radio inputs controlling the rules
   * @param {Record<string, string[]>} options.mapping - Mapping from radio values to selectors of containers to show
   */
  constructor(options = {}) {
    this.ruleRadios = options.ruleRadios;
    this.mapping = options.mapping || {};
  }

  /**
   * Initialize the component (bind events + run initial state).
   * @returns {void}
   */
  init() {
    this._bindEvents();
    this._runInitial();
  }

  /**
   * Bind change events on all radios
   * @private
   * @returns {void}
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
   * @returns {void}
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
   * @returns {void}
   */
  _run(target) {
    this._hideAll();

    // Normalize radio value (snake_case → camelCase)
    const rawValue = target.value;
    const camelValue = rawValue.replace(/_([a-z])/g, (_match, letter) => letter.toUpperCase());

    const selectors = this.mapping[camelValue] || [];

    selectors.forEach((selector) => this._show(selector));
  }

  /**
   * Hide all containers referenced in the mapping
   * @private
   * @returns {void}
   */
  _hideAll() {
    const allSelectors = Object.values(this.mapping).flat();
    allSelectors.forEach((selector) => {
      const el = document.querySelector(selector);
      if (el) {
        el.style.display = "none";
      }
    });
  }

  /**
   * Show a container by selector
   * @param {string} selector - CSS selector of the container to show
   * @private
   * @returns {void}
   */
  _show(selector) {
    const el = document.querySelector(selector);
    if (el) {
      el.style.display = "";
    }
  }
}
