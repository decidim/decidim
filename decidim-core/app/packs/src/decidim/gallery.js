document.addEventListener("turbo:load", () => {
  $(".gallery__container").on("closed.zf.callout", (event) => {
    $(event.target).remove();
  });
});
