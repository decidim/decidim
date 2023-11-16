$(() => {
  const submitBtn = document.getElementById("submit-ballot-recount");
  const modalBtn = document.getElementById("btn-modal-closure-results-count-error");
  const totals = document.querySelectorAll(".form.edit_closure input.total-value");
  const answers = document.querySelectorAll(".form.edit_closure input.answer-value");
  const notas = document.querySelectorAll(".form.edit_closure input.nota-value");
  const modalTotal = document.getElementById("dialog-total-modal-closure-results-count-error");
  const modalValid = document.getElementById("dialog-valid-modal-closure-results-count-error");
  const modalBlank = document.getElementById("dialog-blank-modal-closure-results-count-error");

  const setButtonState = (ok) => {
    if (ok) {
      submitBtn.removeAttribute("hidden");
      modalBtn.setAttribute("hidden", true);
    } else {
      submitBtn.setAttribute("hidden", true);
      modalBtn.removeAttribute("hidden");
    }
  };

  const setModalElement = (element, recount, expected) => {
    if (expected === recount) {
      element.setAttribute("hidden", true);
    } else {
      element.removeAttribute("hidden");
    }
    if (element.querySelector(".expected")) {
      element.querySelector(".expected").innerText = expected;
    }
    if (element.querySelector(".current")) {
      element.querySelector(".current").innerText = recount;
    }
  };

  const checkTotals = () => {
    const totalBallots = Number(document.getElementById("closure_result-total-ballots").dataset.totalBallots);
    let recount = Array.from(totals).reduce((acc, el) => acc + Number(el.value), 0);

    setModalElement(modalTotal, recount, totalBallots);
    return recount === totalBallots;
  };

  const checkValidTotals = () => {
    const totalValid = Number(document.getElementById("closure_result__ballot_results__valid_ballots_count").value);
    let recount = Array.from(answers).reduce((acc, el) => acc + Number(el.value), 0);

    setModalElement(modalValid, recount, totalValid);

    return recount === totalValid;
  };

  const checkBlankTotals = () => {
    const totalBlanks = Number(document.getElementById("closure_result__ballot_results__blank_ballots_count").value);
    let recount = Array.from(notas).reduce((acc, el) => acc + Number(el.value), 0);

    setModalElement(modalBlank, recount, totalBlanks);
    return recount === totalBlanks;
  };

  const runChecks = () => {
    const totalBallots = checkTotals();
    const validTotals = checkValidTotals();
    const blankTotals = checkBlankTotals();

    setButtonState(totalBallots && validTotals && blankTotals);
  };

  if (submitBtn) {
    runChecks();

    [...totals].concat([...answers]).concat([...notas]).forEach((box) => {
      box.addEventListener("blur", runChecks);
    });
  }
});
