$(() => {
  const $confirmButton = $(".destroy-meeting-alert");

  if ($confirmButton.length > 0) {
    console.log($confirmButton.data("proposal-titles"));

    $confirmButton.on("click", () => {
      console.log($confirmButton.data("invalid-destroy-message"));

      let alertText = $confirmButton.data("invalid-destroy-message") + "\n\n";

      alertText += $confirmButton.data("proposal-titles");

      // $confirmButton.data("proposal-titles").forEach((title, index) => {
      //   alertText += `${index + 1}) ${title}\n`
      // });

      alert(alertText);
    });
  }
});
