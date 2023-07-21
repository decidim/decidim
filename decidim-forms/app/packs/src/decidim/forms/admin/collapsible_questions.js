(() => {
  $("button.collapse-all").on("click", () => {
    $(".collapsible").attr('aria-hidden', 'true');
    $(".question--collapse .icon-expand").removeClass("hidden");
    $(".question--collapse .icon-collapse").addClass("hidden");
  });

  $("button.expand-all").on("click", () => {
    $(".collapsible").attr('aria-hidden', 'false');
    $(".question--collapse .icon-expand").addClass("hidden");
    $(".question--collapse .icon-collapse").removeClass("hidden");
  });
})(window);
