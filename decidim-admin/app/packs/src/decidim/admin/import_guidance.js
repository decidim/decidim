$(() => {
  const $creatorDropdownWrapper = $("label[for='import_creator']");
  const $creatorSelect = $("#import_creator");
  const $creatorGuidances = $(".creator-guidances").find(".guidance");

  const classSuffix = (rubyClass) => {
    return rubyClass.split("::").slice(-1)[0].toLowerCase();
  }

  const showTitle = (suffix) => {
    $(`#${suffix}`).show()
    $(`#${suffix}`).siblings().hide()
  }

  const showGuidance = (suffix) => {
    const $elem = $(`.guidance.creator-${suffix}`)
    $elem.show()
    $elem.siblings().hide()
  }

  $creatorSelect.on("change", () => {
    const val = $("#import_creator option:selected").val();
    const suffix = classSuffix(val)
    if (suffix) {
      showGuidance(suffix);
      showTitle(suffix);
    }
  })

  if ($creatorSelect.children("option").length < 2) {
    $creatorDropdownWrapper.hide();
  }

  if ($creatorSelect.length > 0) {
    $creatorGuidances.hide();
    showGuidance(classSuffix($creatorSelect.val()))
    showTitle(classSuffix($creatorSelect.val()));
  }
})
