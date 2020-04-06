(() => {
  $("button.collapse-all").on("click", () => {
    $(".collapsible").addClass("hide");
    $(".question--collapse .icon-expand").removeClass("hide");
    $(".question--collapse .icon-collapse").addClass("hide");
  });

  $("button.expand-all").on("click", () => {
    $(".collapsible").removeClass("hide");
    $(".question--collapse .icon-expand").addClass("hide");
    $(".question--collapse .icon-collapse").removeClass("hide");
  });
})(window);
