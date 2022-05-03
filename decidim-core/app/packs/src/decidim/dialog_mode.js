/**
 * A method to enable the dialog mode for the given dialog(s).
 *
 * This should be called when the dialog is opened. It implements two things for
 * the dialog:
 * 1. It places the focus to the title element making sure the screen reader
 *    focuses in the correct position of the document. Otherwise some screen
 *    readers continue reading outside of the document.
 * 2. Document "tab guards" that force the keyboard focus within the modal when
 *    the user is using keyboard or keyboard emulating devices for browsing the
 *    document.
 *
 * The "tab guards" are added at the top and bottom of the document to keep the
 * user's focus within the dialog if they accidentally or intentionally place
 * the focus outside of the document, e.g. in different window or in the browser
 * address bar. They guard the focus on both sides of the document returning
 * focus back to the first or last focusable element within the dialog.
 *
 * @param {jQuery} $dialogs The jQuery element(s) to apply the mode for.
 * @return {Void} Nothing
 */
export default ($dialogs) => {
  $dialogs.each((_i, dialog) => {
    const $dialog = $(dialog);

    const $container = $("body");
    const $title = $(".reveal__title:first", $dialog);

    if ($title.length > 0) {
      // Focus on the title to make the screen reader to start reading the
      // content within the modal.
      $title.attr("tabindex", $title.attr("tabindex") || -1);
      $title.trigger("focus");
    }

    // Once the final modal closes, disable the focus guarding
    $dialog.off("closed.zf.reveal.focusguard").on("closed.zf.reveal.focusguard", () => {
      $dialog.off("closed.zf.reveal.focusguard");

      // After the last dialog is closed, the tab guards should be removed.
      // This is done when the focus guard is disabled. If there is still a
      // visible reveal item in the DOM, make that the currently "guarded"
      // element. Note that there may be multiple dialogs open on top of each
      // other at the same time.
      const $visibleReveal = $(".reveal:visible:last", $container);
      if ($visibleReveal.length > 0) {
        window.focusGuard.trap($visibleReveal[0]);
      } else {
        window.focusGuard.disable();
      }
    });

    window.focusGuard.trap(dialog);
  });
};
