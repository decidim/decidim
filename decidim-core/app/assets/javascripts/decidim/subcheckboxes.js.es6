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
        const indeterminateInputs = document.querySelectorAll(
          '#' + checksContext + " input[type='checkbox']:indeterminate"
        );

        if (checkedInputs.length === 0) {
          e.checked = false;
          e.indeterminate = false;
        } else if (checkedInputs.length === totalInputs.length && indeterminateInputs.length == 0) {
          e.checked = true;
          e.indeterminate = false;
        } else {
          e.checked = true;
          e.indeterminate = true;
        }

        totalInputs.forEach((input) => {
          if (e.indeterminate && !input.indeterminate) {
            input.classList.remove("ignore-filter");
          } else {
            input.classList.add("ignore-filter");
          }
          const subfilters = input.parentNode.parentNode.nextElementSibling;
          if (subfilters && subfilters.classList.contains("filters__subfilters")) {
            if (input.indeterminate)
              subfilters.classList.remove("ignore-filters");
            else
              subfilters.classList.add("ignore-filters");
          }
        });
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
        e.classList.add("ignore-filter");
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
        '#' + checkBoxContext + '> div > [data-children-checkbox] > input'
      );
      const checkedSiblings = document.querySelectorAll(
        '#' + checkBoxContext + '> div > [data-children-checkbox] > input:checked'
      );
      const indeterminateSiblings = document.querySelectorAll(
        '#' + checkBoxContext + '> div > [data-children-checkbox] > input:indeterminate'
      );

      if (checkedSiblings.length === 0) {
        parentCheck.checked = false;
        parentCheck.indeterminate = false;
      } else if (checkedSiblings.length === totalCheckSiblings.length && indeterminateSiblings.length == 0) {
        parentCheck.checked = true;
        parentCheck.indeterminate = false;
      } else {
        parentCheck.checked = true;
        parentCheck.indeterminate = true;
      }

      totalCheckSiblings.forEach((input) => {
        if (e.indeterminate && !input.indeterminate) {
          input.classList.remove("ignore-filter");
        } else {
          input.classList.add("ignore-filter");
        }
        const subfilters = input.parentNode.parentNode.nextElementSibling;
        if (subfilters && subfilters.classList.contains("filters__subfilters")) {
          if (input.indeterminate)
            subfilters.classList.remove("ignore-filters");
          else
            subfilters.classList.add("ignore-filters");
        }
      });

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
