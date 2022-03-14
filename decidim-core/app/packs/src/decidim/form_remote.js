import Rails from "@rails/ujs";

// Make the remote form submit buttons disabled when the form is being
// submitted to avoid multiple submits.
document.addEventListener("ajax:beforeSend", (ev) => {
  if (!ev.target.matches("form[data-remote]")) {
    return;
  }

  ev.target.querySelectorAll("[type=submit]").forEach((submit) => {
    submit.disabled = true;
  });
});
document.addEventListener("ajax:complete", (ev) => {
  if (!ev.target.matches("form[data-remote]")) {
    return;
  }

  ev.target.querySelectorAll("[type=submit]").forEach((submit) => {
    submit.disabled = false;
  });
});

// The forms that are attached to Foundation Abide do not work properly with
// Rails UJS Ajax forms that have the `data-remote` attribute attached to
// them. The reason is that in case Foundation Abide sees the form as valid,
// it will submit it normally bypassing the Rails UJS functionality.
// The submit events happens through jQuery in Foundation Abide which is why
// we need to bind the event with jQuery.
$(document).on("submit", "form[data-remote][data-abide]", (ev) => {
  ev.preventDefault();

  if (ev.target.querySelectorAll("[data-invalid]").length > 0) {
    return;
  }

  Reflect.apply(Rails.handleRemote, ev.target, [ev]);
});
