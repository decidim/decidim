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

  const detectCreator = (queryString) => {
    const urlParams = new URLSearchParams(queryString);
    const creatorParam = urlParams.get("creator");
    let found = false;

    $creatorSelect.find("option").each((_i, option) => {
      const suffix = classSuffix(option.value)
      if (suffix === creatorParam.toLocaleLowerCase()) {
        $creatorSelect.val(option.value);
        found = true
      } else {
        $(`#${suffix}`).hide();
      }
    })

    if (found) {
      $creatorDropdownWrapper.hide();
    }
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
  } else if (window.location.search) {
    detectCreator(window.location.search);
  }

  $creatorGuidances.hide();
  showGuidance(classSuffix($creatorSelect.val()))
  showTitle(classSuffix($creatorSelect.val()));
})
