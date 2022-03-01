$(() => {
  const $allDiffViews = $(".row.diff_view");

  $(document).on("click", ".diff-view-by a.diff-view-mode", (event) => {
    event.preventDefault();
    const $target = $(event.target)
    let type = "escaped";
    const $selected = $target.parents(".is-dropdown-submenu-parent").find("#diff-view-selected");
    if ($selected.text().trim() === $target.text().trim()) {
      return;
    }

    $selected.text($target.text());

    if ($target.attr("id") === "diff-view-unified") {
      if ($(".row.diff_view_split_escaped").hasClass("hide")) {
        type = "unescaped";
      }

      $allDiffViews.addClass("hide");
      $(`.row.diff_view_unified_${type}`).removeClass("hide");
    }
    if ($target.attr("id") === "diff-view-split") {
      if ($(".row.diff_view_unified_escaped").hasClass("hide")) {
        type = "unescaped";
      }

      $allDiffViews.addClass("hide");
      $(`.row.diff_view_split_${type}`).removeClass("hide");
    }
  })

  $(document).on("click", ".diff-view-by a.diff-view-html", (event) => {
    event.preventDefault();
    const $target = $(event.target);
    $target.parents(".is-dropdown-submenu-parent").find("#diff-view-html-selected").text($target.text());
    const $visibleDiffViewsId = $allDiffViews.not(".hide").first().attr("id").split("_").slice(1, -1).join("_");
    const $visibleDiffViews = $allDiffViews.filter(`[id*=${$visibleDiffViewsId}]`)

    if ($target.attr("id") === "diff-view-escaped-html") {
      $visibleDiffViews.filter("[id$=_unescaped]").addClass("hide");
      $visibleDiffViews.filter("[id$=_escaped]").removeClass("hide");
    }
    if ($target.attr("id") === "diff-view-unescaped-html") {
      $visibleDiffViews.filter("[id$=_escaped]").addClass("hide");
      $visibleDiffViews.filter("[id$=_unescaped]").removeClass("hide");
    }
  })
});
