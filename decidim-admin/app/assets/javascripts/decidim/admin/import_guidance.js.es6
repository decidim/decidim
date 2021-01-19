(() => {
  const $creatorSelect = $("#import_creator");
  const $creatorGuidances = $(".creator-guidances").find(".guidance");

  const showGuidance = (text) => {
    const formatted = text.replace(/\s/g, "").toLocaleLowerCase();
    $.each($creatorGuidances, (_index, currentValue) => {
      if (currentValue.className.includes(formatted)) {
        const elem = $(currentValue)
        elem.show();
      }
    })
  }

  $creatorSelect.on("change", function() {
    const text = $("#import_creator option:selected").text()
    $creatorGuidances.hide();
    if (text) {
      showGuidance(text)
    }
  })

  $creatorGuidances.hide();
  $creatorGuidances.first().show();
})();

