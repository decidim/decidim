function getDismissedHelpers() {
  let serialized = localStorage.getItem("dismissedHelpers");

  if (serialized) {
    return serialized.split(",");
  } else {
    return [];
  }
}

function addDismissedHelper(id) {
  let dismissedHelpers = getDismissedHelpers();

  if (!dismissedHelpers.includes(id)) {
    localStorage.setItem(
      "dismissedHelpers",
      [...dismissedHelpers, id].join(",")
    );
  }
}

$(function() {
  if (!window.localStorage) return;
  let dismissedHelpers = getDismissedHelpers();

  $(".floating-helper-container").each((_index, elem) => {
    let id = $(elem).data("help-id");

    if (!dismissedHelpers.includes(id)) {
      $(".floating-helper", elem).foundation("toggle");
      $(".floating-helper__wrapper", elem).foundation("toggle");

      $(".floating-helper", elem).on("off.zf.toggler", e => {
        addDismissedHelper(id);
      });
    }
  });
});
