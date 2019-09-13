let translate = function (originalText, targetLang, callback) {
  if (originalText !== "" && targetLang !== "") {
    $.ajax({
      url: "/api/translate",
      type: "POST",
      // data: `target=${targetLang}&original=${originalText}`,
      data: {
        target: targetLang,
        original: originalText,
        "authenticity_token": window.$('meta[name="csrf-token"]').attr("content")
      },
      dataType: "json",
      success: function (body) {
        callback([body.translations[0].detected_source_language, body.translations[0].text]);
      },
      error: function (body, status, error) {
        throw error;
      }
    });
  }
};


$(() => {
  $(".translatable_btn").on("click", (event) => {
    event.preventDefault();
    const $item = $(event.delegateTarget);
    const $spinner = $item.children(".loading-spinner");
    const $btn = $item.children("span");

    const original = $item.data("original");
    const translated = $item.data("translated");
    const targetLang = $item.data("targetlang");
    const targetelement = $item.data("targetelem");

    let translatable = $item.data("translatable");
    let originalTitle = $item.data("title");
    let originalBody = $item.data("body");

    const $title = $(`#${targetelement}_title`);
    const $body = $(`#${targetelement}_body`);

    if (translatable) {
      $spinner.removeClass("loading-spinner--hidden");

      translate(originalTitle, targetLang, (response) => {
        $item.data("title", $title.text());
        $title.text(response[1]);
      });

      translate(originalBody, targetLang, (response) => {
        $item.data("body", $body.html());
        $body.html(response[1]);

        $btn.text(translated);

        $spinner.addClass("loading-spinner--hidden");

        $item.data("translatable", false);
      });
    } else {
      $btn.text(original);
      $title.text(originalTitle);
      $body.html(decodeURI(originalBody));
      $item.data("translatable", true);
    }
  })
});
