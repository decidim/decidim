$(() => {
  function subCheckBoxes() {
    const subCheckboxes = document.querySelectorAll('[data-sub-checkboxes]');
    if (!subCheckboxes) {
      return;
    }

    function checkTheCheckBoxes() {
      //Quis custodiet ipsos custodes?
      const targetChecks = this.dataset.subCheckboxes;
      const checkStatus = this.checked;
      const allChecks = document.querySelectorAll(
        '#' + targetChecks + " input[type='checkbox']"
      );
      allChecks.forEach(function(e) {
        e.checked = checkStatus;
      });
    }

    subCheckboxes.forEach(function(e) {
      e.addEventListener('click', checkTheCheckBoxes);
    });
  }

  subCheckBoxes();
});
