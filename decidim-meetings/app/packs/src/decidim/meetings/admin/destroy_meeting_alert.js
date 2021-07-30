const removeNewlineAdjacentSpaces = (text) => {
  return text.replace(/\n\s/g, "\n");
}

$(() => {
  const $confirmButton = $(".destroy-meeting-alert");

  if ($confirmButton.length > 0) {
    $confirmButton.on("click", () => {
      let alertText = `${$confirmButton.data("invalid-destroy-message")} \n\n`;
      alertText += removeNewlineAdjacentSpaces($confirmButton.data("proposal-titles"));

      alert(alertText); // eslint-disable-line no-alert
    });
  }
});
