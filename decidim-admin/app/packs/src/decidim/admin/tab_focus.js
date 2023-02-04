/**
 * When switching tabs in i18n fields, autofocus on the input to save clicks #212
 */
$(() => {
  // Event launched by foundation
  $("[data-tabs]").on("change.zf.tabs", (event) => {
    const $container = $(event.target).parent().next(".tabs-content").find(".tabs-panel.is-active");
    // Detect rich text editor inside the tabs-panel
    let $content = $container.find(".editor .ProseMirror");
    if ($content.length > 0) {
      $content.focus();
    // Detect if inside the tabs-panel have an input
    } else {
      $content = $container.find("input:first");
      if ($content.length > 0) {
        $content.focus();
      }
    }
  });
});
