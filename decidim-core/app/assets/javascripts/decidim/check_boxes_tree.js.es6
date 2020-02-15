/**
 * Checkboxes tree component.
 */
class CheckBoxesTree {
  constructor() {
    this.checkboxesTree = document.querySelectorAll("[data-checkboxes-tree]");
    if (!this.checkboxesTree) {
      return;
    }

    this.globalChecks = document.querySelectorAll("[data-global-checkbox] input");
    this.globalChecks.forEach((global) => {
      if (global.value === "") {
        global.classList.add("ignore-filter")
      }
    });
    this.checkGlobalCheck();

    // Event listeners
    this.checkboxesTree.forEach((input) => input.addEventListener("click", this.checkTheCheckBoxes));
    document.querySelectorAll("[data-children-checkbox] input").forEach((input) => {
      input.addEventListener("change", (event) => this.checkTheCheckParent(event.target));
    });

    // Review parent checkboxes on initial load
    document.querySelectorAll("[data-children-checkbox] input").forEach((input) => {
      this.checkTheCheckParent(input);
    });
  }

  /**
   * Handles the click action on any checkbox.
   * @private
   * @param {Event} event - the click event related information
   * @returns {Void} - Returns nothing.
   */
  checkTheCheckBoxes(event) {
    // Quis custodiet ipsos custodes?
    const targetChecks = event.target.dataset.checkboxesTree;
    const checkStatus = event.target.checked;
    const allChecks = document.querySelectorAll(`#${targetChecks} input[type='checkbox']`);

    allChecks.forEach((input) => {
      input.checked = checkStatus;
      input.indeterminate = false;
      input.classList.add("ignore-filter");
    });
  }

  /**
   * Update global checkboxes state when the currention selection changes
   * @private
   * @returns {Void} - Returns nothing.
   */
  checkGlobalCheck() {
    this.globalChecks.forEach((global) => {
      const checksContext = global.dataset.checkboxesTree;
      const totalInputs = document.querySelectorAll(
        `#${checksContext} input[type='checkbox']`
      );
      const checkedInputs = document.querySelectorAll(
        `#${checksContext} input[type='checkbox']:checked`
      );
      const indeterminateInputs = document.querySelectorAll(
        `#${checksContext} input[type='checkbox']:indeterminate`
      );

      if (checkedInputs.length === 0) {
        global.checked = false;
        global.indeterminate = false;
      } else if (checkedInputs.length === totalInputs.length && indeterminateInputs.length === 0) {
        global.checked = true;
        global.indeterminate = false;
      } else {
        global.checked = true;
        global.indeterminate = true;
      }

      totalInputs.forEach((input) => {
        if (global.indeterminate && !input.indeterminate) {
          input.classList.remove("ignore-filter");
        } else {
          input.classList.add("ignore-filter");
        }
        const subfilters = input.parentNode.parentNode.nextElementSibling;
        if (subfilters && subfilters.classList.contains("filters__subfilters")) {
          if (input.indeterminate) {
            subfilters.classList.remove("ignore-filters");
          } else {
            subfilters.classList.add("ignore-filters");
          }
        }
      });
    });
  }

  /**
   * Update children checkboxes state when the currention selection changes
   * @private
   * @param {Input} input - the checkbox to check its parent
   * @returns {Void} - Returns nothing.
   */
  checkTheCheckParent(input) {
    const checkBoxContext = input.parentNode.parentNode.parentNode.getAttribute("id");
    if (!checkBoxContext) {
      this.checkGlobalCheck();
      return;
    }

    const parentCheck = document.querySelector(
      `[data-checkboxes-tree=${checkBoxContext}]`
    );
    const totalCheckSiblings = document.querySelectorAll(
      `#${checkBoxContext} > div > [data-children-checkbox] > input`
    );
    const checkedSiblings = document.querySelectorAll(
      `#${checkBoxContext} > div > [data-children-checkbox] > input:checked`
    );
    const indeterminateSiblings = document.querySelectorAll(
      `#${checkBoxContext} > div > [data-children-checkbox] > input:indeterminate`
    );

    if (checkedSiblings.length === 0) {
      parentCheck.checked = false;
      parentCheck.indeterminate = false;
    } else if (checkedSiblings.length === totalCheckSiblings.length && indeterminateSiblings.length === 0) {
      parentCheck.checked = true;
      parentCheck.indeterminate = false;
    } else {
      parentCheck.checked = true;
      parentCheck.indeterminate = true;
    }

    totalCheckSiblings.forEach((sibling) => {
      if (parent.indeterminate && !sibling.indeterminate) {
        sibling.classList.remove("ignore-filter");
      } else {
        sibling.classList.add("ignore-filter");
      }
      const subfilters = sibling.parentNode.parentNode.nextElementSibling;
      if (subfilters && subfilters.classList.contains("filters__subfilters")) {
        if (sibling.indeterminate) {
          subfilters.classList.remove("ignore-filters");
        } else {
          subfilters.classList.add("ignore-filters");
        }
      }
    });

    this.checkTheCheckParent(parentCheck);
  }
}

$(() => new CheckBoxesTree());
