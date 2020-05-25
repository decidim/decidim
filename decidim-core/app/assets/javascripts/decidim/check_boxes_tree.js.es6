/**
 * CheckBoxesTree component.
 */
((exports) => {
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
      this.checkboxesTree.forEach((input) => input.addEventListener("click", (event) => this.checkTheCheckBoxes(event.target)));
      document.querySelectorAll("[data-children-checkbox] input").forEach((input) => {
        input.addEventListener("change", (event) => this.checkTheCheckParent(event.target));
      });

      // Review parent checkboxes on initial load
      document.querySelectorAll("[data-children-checkbox] input").forEach((input) => {
        this.checkTheCheckParent(input);
      });
    }

    /**
     * Set checkboxes as checked if included in given values
     * @public
     * @param {Array} checkboxes - array of checkboxs to check
     * @param {Array} values - values of checkboxes that should be checked
     * @returns {Void} - Returns nothing.
     */
    updateChecked(checkboxes, values) {
      checkboxes.each((index, checkbox) => {
        if ((checkbox.value === "" && values.length === 1) || (checkbox.value !== "" && values.includes(checkbox.value))) {
          checkbox.checked = true;
          this.checkTheCheckBoxes(checkbox);
          this.checkTheCheckParent(checkbox);
        }
      });
    }

    /**
     * Set the container form(s) for the component, to disable ignored filters before submitting them
     * @public
     * @param {query} theForm - form or forms where the component will be used
     * @returns {Void} - Returns nothing.
     */
    setContainerForm(theForm) {
      theForm.on("submit ajax:before", () => {
        theForm.find(".ignore-filters input, input.ignore-filter").each((idx, elem) => {
          elem.disabled = true;
        });
      });

      theForm.on("ajax:send", () => {
        theForm.find(".ignore-filters input, input.ignore-filter").each((idx, elem) => {
          elem.disabled = false;
        });
      });
    }

    /**
     * Handles the click action on any checkbox.
     * @private
     * @param {Input} target - the input that has been checked
     * @returns {Void} - Returns nothing.
     */
    checkTheCheckBoxes(target) {
      // Quis custodiet ipsos custodes?
      const targetChecks = target.dataset.checkboxesTree;
      const checkStatus = target.checked;
      const allChecks = document.querySelectorAll(`#${targetChecks} input[type='checkbox']`);

      allChecks.forEach((input) => {
        input.checked = checkStatus;
        input.indeterminate = false;
        input.classList.add("ignore-filter");
      });
    }

    /**
     * Update global checkboxes state when the current selection changes
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
        const indeterminateInputs = Array.from(totalInputs).filter((checkbox) => checkbox.indeterminate)

        if (checkedInputs.length === 0 && indeterminateInputs.length === 0) {
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
     * Update children checkboxes state when the current selection changes
     * @private
     * @param {Input} input - the checkbox to check its parent
     * @returns {Void} - Returns nothing.
     */
    checkTheCheckParent(input) {
      const checkBoxContext = $(input).parents(".filters__subfilters").attr("id");
      if (!checkBoxContext) {
        this.checkGlobalCheck();
        return;
      }

      const parentCheck = document.querySelector(
        `[data-checkboxes-tree=${checkBoxContext}]`
      );
      const totalCheckSiblings = document.querySelectorAll(
        `#${checkBoxContext} > div > [data-children-checkbox] > input, #${checkBoxContext} > [data-children-checkbox] > input`
      );
      const checkedSiblings = document.querySelectorAll(
        `#${checkBoxContext} > div > [data-children-checkbox] > input:checked, #${checkBoxContext} > [data-children-checkbox] > input:checked`
      );
      const indeterminateSiblings = Array.from(totalCheckSiblings).filter((checkbox) => checkbox.indeterminate)

      if (checkedSiblings.length === 0 && indeterminateSiblings.length === 0) {
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

  exports.Decidim = exports.Decidim || {};
  exports.Decidim.CheckBoxesTree = CheckBoxesTree;
})(window);
