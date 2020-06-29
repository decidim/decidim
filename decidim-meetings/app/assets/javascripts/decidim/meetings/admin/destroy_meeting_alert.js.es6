$(() => {
  const $confirmButton = $(".destroy-meeting-alert");

  if ($confirmButton.length > 0) {
    $confirmButton.on("click", () => {
      let alertText = $confirmButton.data("invalid-destroy-message") + "\n\n";
      alertText += $confirmButton.data("proposal-titles");

      alert(alertText);
    });
  }
});
