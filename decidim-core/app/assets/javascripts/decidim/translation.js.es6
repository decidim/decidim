let translate = function (originalText, targetLang, callback) {
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
};


$(() => {
  $(".translatable_btn").on("click", (event) => {
    event.preventDefault();
    const $item = $(event.delegateTarget);
    const $spinner = $item.children(".loading-spinner");
    const $btn = $item.children("span");

    let $title = null;
    let $body = null;

    const original = $item.data("original");
    const translated = $item.data("translated");
    const translatableId = $item.data("translatable-id");
    const targetLang = $item.data("targetlang");
    const tranlatableType = $item.data("translatabletype");

    let translatable = $item.data("translatable");
    let originalTitle = $item.data("title");
    let originalBody = $item.data("body");

    switch (tranlatableType) {
    case "card-m":
      $title = $item.parentsUntil("[data-translatable-parent]").find("[data-translatable-title]");
      $body = $item.parentsUntil("[data-translatable-parent]").find("[data-translatable-body]");
      break;
    case "proposal-show":
      $title = $(document).find(`[data-translatable-title=${translatableId}]`);
      $body = $(document).find(`[data-translatable-body=${translatableId}]`);
      break;
    default:
      throw new Error("No translatable type");
    }

    if (translatable) {
      $spinner.removeClass("loading-spinner--hidden");

      translate($title.text(), targetLang, (response) => {
        $item.data("title", $title.text());
        $title.text(response[1]);
      });

      translate($body.html(), targetLang, (response) => {
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
