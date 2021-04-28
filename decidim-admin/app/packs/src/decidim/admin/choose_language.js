/* eslint-disable no-invalid-this */

$(() => {
  $("select.language-change").change(function () {
    let $select = $(this);
    let targetTabPaneSelector = $select.val();
    let $tabsContent = $select.parent().parent().siblings();

    $tabsContent.children(".is-active").removeClass("is-active");
    $tabsContent.children(targetTabPaneSelector).addClass("is-active");
  })
});
