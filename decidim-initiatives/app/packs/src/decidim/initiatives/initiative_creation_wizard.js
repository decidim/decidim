$(() => {
  const selectInitiativeType = document.getElementById("select-initiative-type");

  if (selectInitiativeType) {
    const submitButton = selectInitiativeType.querySelector('button[type="submit"]');
    const radioButtons = selectInitiativeType.querySelectorAll('input[type="radio"][name="initiative[type_id]"]');

    submitButton.disabled = true;

    for (const radioButton of radioButtons) {
      radioButton.addEventListener("click", () => {
        submitButton.disabled = false;
      });
    }
  }
});
