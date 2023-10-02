$(() => {
  // Auto scroll to show the menu on the viewport
  // @see: https://github.com/decidim/decidim/issues/11307
  $(document).on("click", "[data-component='dropdown'][data-scroll-to-menu='true']", (ev) => {
    const $target = $(ev.currentTarget);
    if ($target.attr("aria-expanded") === "true") {
      window.scrollTo({ top: $target.offset().top, behavior: "smooth" });
    }
  });
});
