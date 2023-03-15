import select from "select";

/**
 * This provides functionality to add clipboard copy functionality to buttons
 * on the page. The element to be copied from has to be defined for the button
 * using a `data` attribute and the target element has to be a form input.
 *
 * Usage:
 *   1. Create the button:
 *     <button class="button"
 *      data-clipboard-copy="#target-input-element"
 *      data-clipboard-copy-label="Copied!"
 *      data-clipboard-copy-message="The text was successfully copied to clipboard."
 *      aria-label="Copy the text to clipboard">
 *        <%= icon "clipboard", role: "presentation", "aria-hidden": true %>
 *        Copy to clipboard
 *    </button>
 *
 *   2. Make sure the target element exists on the page:
 *     <input id="target-input-element" type="text" value="This text will be copied.">
 *
 * Options through data attributes:
 * - `data-clipboard-copy` = The jQuery selector for the target input element
 *   where text will be copied from.
 * - `data-clipboard-copy-label` = The label that will be shown in the button
 *   after a succesful copy.
 * - `data-clipboard-copy-message` = The text that will be announced to screen
 *   readers after a successful copy.
 */

// How long the "copied" text is shown in the copy element after successful
// copy.
const CLIPBOARD_COPY_TIMEOUT = 5000;

$(() => {
  $(document).on("click", "[data-clipboard-copy]", (ev) => {
    const $el = $(ev.currentTarget);
    if (!$el.data("clipboard-copy") || $el.data("clipboard-copy").length < 1) {
      return;
    }

    const $input = $($el.data("clipboard-copy"));
    if ($input.length < 1 || !$input.is("input, textarea, select")) {
      return;
    }

    // Get the available text to clipboard.
    const selectedText = select($input[0]);
    if (!selectedText || selectedText.length < 1) {
      return;
    }

    // Move the selected text to clipboard.
    const $temp = $(`<textarea>${selectedText}</textarea>`).css({
      width: 1,
      height: 1
    });
    $el.after($temp);
    $temp.select();

    const copyDone = () => {
      $temp.remove();
      $el.focus();
    };
    try {
      // document.execCommand is deprecated but the Clipboard API is not
      // supported by IE (which unfortunately is still a thing).
      if (!document.execCommand("copy")) {
        return;
      }
    } catch (err) {
      copyDone();
      return;
    }
    copyDone();

    // Change the label to indicate the copying was successful.
    const label = $el.data("clipboard-copy-label");
    if (label) {
      let to = $el.data("clipboard-copy-label-timeout");
      if (to) {
        clearTimeout(to);
      }

      if (!$el.data("clipboard-copy-label-original")) {
        $el.data("clipboard-copy-label-original", $el.html());
      }

      $el.html(label);
      to = setTimeout(() => {
        $el.html($el.data("clipboard-copy-label-original"));
        $el.removeData("clipboard-copy-label-original");
        $el.removeData("clipboard-copy-label-timeout");
      }, CLIPBOARD_COPY_TIMEOUT);
      $el.data("clipboard-copy-label-timeout", to)
    }

    // Alert the screen reader what just happened (the link was copied).
    let message = $el.data("clipboard-copy-message");
    if (message) {
      let $msg = $el.data("clipboard-message-element");
      if ($msg) {
        if ($msg.html() === message) {
          // Try to hint the screen reader to re-read the text in the message
          // element.
          message += "&nbsp;";
        }
      } else {
        $msg = $('<div aria-role="alert" aria-live="assertive" aria-atomic="true" class="sr-only"></div>');
        $el.after($msg);
        $el.data("clipboard-message-element", $msg);
      }

      // Add the non breaking space always to content to try to force the
      // screen reader to reannounce the added text.
      $msg.html(message);
    }
  });
});
