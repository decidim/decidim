$(() => {
  const $allDiffViews = $(".row[id^=diff_view_]");

  $(document).on("click", ".diff-view-by a.diff-view-mode", (event) => {
    event.preventDefault();
    const $target = $(event.target);
    $target.parents(".is-dropdown-submenu-parent").find("#diff-view-selected").text($target.text());

    if ($target.attr("id") === "diff-view-unified") {
      $allDiffViews.addClass("hide");
      $(".row#diff_view_unified_escaped").removeClass("hide");
    }
    if ($target.attr("id") === "diff-view-split") {
      $allDiffViews.addClass("hide");
      $(".row#diff_view_split_escaped").removeClass("hide");
    }
  })

  $(document).on("click", ".diff-view-by a.diff-view-html", (event) => {
    event.preventDefault();
    const $target = $(event.target);
    $target.parents(".is-dropdown-submenu-parent").find("#diff-view-selected").text($target.text());
    const $visibleDiffViewsId = $allDiffViews.not(".hide").first().attr("id").split("_").slice(0, -1).join("_");
    const $visibleDiffViews = $allDiffViews.filter(`[id^=${$visibleDiffViewsId}]`)

    if ($target.attr("id") === "escaped-html") {
      $visibleDiffViews.filter("[id$=_unescaped]").addClass("hide");
      $visibleDiffViews.filter("[id$=_escaped]").removeClass("hide");
    }
    if ($target.attr("id") === "unescaped-html") {
      $visibleDiffViews.filter("[id$=_escaped]").addClass("hide");
      $visibleDiffViews.filter("[id$=_unescaped]").removeClass("hide");
    }
  })


});
