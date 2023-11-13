/**
 * CheckBoxesTree component.
 */
export default class CheckBoxesTree {
  constructor() {
    this.checkboxesTree = Array.from(document.querySelectorAll("[data-checkboxes-tree]"));

    if (!this.checkboxesTree.length) {
      return;
    }

    this.checkboxesLeaf = Array.from(document.querySelectorAll("[data-children-checkbox] input"));

    // handles the click in a tree, what means to mark/unmark every children
    this.checkboxesTree.forEach((input) => input.addEventListener("click", (event) => this.checkTheCheckBoxes(event.target)));
    // handles the click in a leaf, what means to update the parent possibly
    this.checkboxesLeaf.forEach((input) => input.addEventListener("change", (event) => this.checkTheCheckParent(event.target)));
    // Review parent checkboxes on initial load
    this.checkboxesLeaf.forEach((input) => this.checkTheCheckParent(input));
  }

  /**
   * Set checkboxes as checked if included in given values
   * @public
   * @param {Array} checkboxes - array of checkboxs to check
   * @param {Array} values - values of checkboxes that should be checked
   * @returns {Void} - Returns nothing.
   */
  updateChecked(checkboxes, values) {
    checkboxes.each((_idx, checkbox) => {
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
      theForm.find(".ignore-filters input, input.ignore-filter").each((_idx, elem) => {
        elem.disabled = true;
      });
    });

    theForm.on("ajax:send", () => {
      theForm.find(".ignore-filters input, input.ignore-filter").each((_idx, elem) => {
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
    const targetChecks = target.dataset.checkboxesTree;
    const checkStatus = target.checked;
    // NOTE: Note the regex CSS query, it selects those [data-children-checkbox] ended with the target id
    const allChecks = document.querySelectorAll(`[data-children-checkbox$="${targetChecks}"] input`);

    allChecks.forEach((input) => {
      input.checked = checkStatus;
      input.indeterminate = false;
      input.classList.add("ignore-filter");

      // recursive call if the input it is also a tree
      if (input.dataset.checkboxesTree) {
        this.checkTheCheckBoxes(input)
      }
    });
  }

  /**
   * Update children checkboxes state when the current selection changes
   * @private
   * @param {Input} input - the checkbox to check its parent
   * @returns {Void} - Returns nothing.
   */
  checkTheCheckParent(input) {
    const key = input.parentNode.dataset.childrenCheckbox
    // search in the checkboxes array if some id ends with the childrenCheckbox key, what means it is the parent
    const parentCheck = this.checkboxesTree.find(({ id }) => new RegExp(`${key}$`, "i").test(id))

    if (typeof parentCheck === "undefined") {
      return;
    }

    // search for leaves with the same parent, what means they are siblings
    const totalCheckSiblings = this.checkboxesLeaf.filter((node) => node.parentNode.dataset.childrenCheckbox === key)
    const checkedSiblings = totalCheckSiblings.filter((checkbox) => checkbox.checked)
    const indeterminateSiblings = totalCheckSiblings.filter((checkbox) => checkbox.indeterminate)

    if (checkedSiblings.length === 0 && indeterminateSiblings.length === 0) {
      parentCheck.checked = false;
      parentCheck.indeterminate = false;
    } else if (checkedSiblings.length === totalCheckSiblings.length && indeterminateSiblings.length === 0) {
      parentCheck.checked = true;
      parentCheck.indeterminate = false;
    } else {
      parentCheck.checked = false;
      parentCheck.indeterminate = true;
    }

    totalCheckSiblings.forEach((sibling) => {
      if (parentCheck.indeterminate && !sibling.indeterminate) {
        sibling.classList.remove("ignore-filter");
      } else {
        sibling.classList.add("ignore-filter");
      }
    });

    // recursive call if there are more children
    if ("childrenCheckbox" in parentCheck.parentNode.dataset) {
      this.checkTheCheckParent(parentCheck);
    }
  }
}
