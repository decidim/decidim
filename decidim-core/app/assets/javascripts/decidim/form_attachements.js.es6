$(() => {
  $("form .attachments_container").on("closed.zf.callout", (event) => {
    $(event.target).remove();
  });
});
