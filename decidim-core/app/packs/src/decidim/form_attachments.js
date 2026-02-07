document.addEventListener("turbo:load", () => {
  $("form .attachments_container").on("closed.zf.callout", (event) => {
    $(event.target).remove();
  });
});
