$(() => {
  function subCheckBoxes() {
    const subCheckboxes = document.querySelectorAll('[data-sub-checkboxes]');
    if (!subCheckboxes) {
      return;
    }

    function checkGlobalCheck() {
      const globalChecks = document.querySelectorAll(
        '[data-global-checkbox] input'
      );
      globalChecks.forEach(function(e) {
        const checksContext = e.dataset.subCheckboxes;
        const totalInputs = document.querySelectorAll(
          '#' + checksContext + " input[type='checkbox']"
        );
        const checkedInputs = document.querySelectorAll(
          '#' + checksContext + " input[type='checkbox']:checked"
        );
        if (checkedInputs.length === 0) {
          e.checked = false;
          e.indeterminate = false;
        } else if (checkedInputs.length === totalInputs.length) {
          e.checked = true;
          e.indeterminate = false;
        } else {
          e.checked = true;
          e.indeterminate = true;
        }
      });
    }

    function checkTheCheckBoxes(e) {
      //Quis custodiet ipsos custodes?
      const targetChecks = this.dataset.subCheckboxes;
      const checkStatus = this.checked;
      const allChecks = document.querySelectorAll(
        '#' + targetChecks + " input[type='checkbox']"
      );
      allChecks.forEach(function(e) {
        e.checked = checkStatus;
        e.indeterminate = false;
      });
    }
    function checkTheCheckParent(e) {
      let $this = this || e;

      const checkBoxContext = $this.parentNode.parentNode.parentNode.getAttribute('id');
      
      if (!checkBoxContext) {
        checkGlobalCheck();
        return;
      }
      const parentCheck = document.querySelector(
        '[data-sub-checkboxes=' + checkBoxContext + ']'
      );
      const totalCheckSiblings = document.querySelectorAll(
        '#' + checkBoxContext + '> div > [data-children-checkbox] input'
      );
      const checkedSiblings = document.querySelectorAll(
        '#' + checkBoxContext + '> div > [data-children-checkbox] input:checked'
      );

      if (checkedSiblings.length === 0) {
        parentCheck.checked = false;
        parentCheck.indeterminate = false;
      } else if (checkedSiblings.length === totalCheckSiblings.length) {
        parentCheck.checked = true;
        parentCheck.indeterminate = false;
      } else {
        parentCheck.checked = true;
        parentCheck.indeterminate = true;
      }

      checkTheCheckParent(parentCheck);
    }

    // Event listeners
    subCheckboxes.forEach(function(e) {
      e.addEventListener('click', checkTheCheckBoxes);
    });
    document
      .querySelectorAll('[data-children-checkbox] input')
      .forEach(function(e) {
        e.addEventListener('change', checkTheCheckParent);
      });

    // Review parent checkboxes on initial load
    document
      .querySelectorAll('[data-children-checkbox] input')
      .forEach(function(e) {
        checkTheCheckParent(e);
      });
    checkGlobalCheck();
  }

  //Init this function
  subCheckBoxes();
});
