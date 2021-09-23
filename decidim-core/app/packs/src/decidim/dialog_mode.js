const focusGuardClass = "focusguard";
const focusableNodes = ["A", "IFRAME", "OBJECT", "EMBED"];
const focusableDisableableNodes = ["BUTTON", "INPUT", "TEXTAREA", "SELECT"];

const isFocusGuard = (element) => {
  return element.classList.contains(focusGuardClass);
}

const isFocusable = (element) => {
  if (focusableNodes.indexOf(element.nodeName) > -1) {
    return true;
  }
  if (focusableDisableableNodes.indexOf(element.nodeName) > -1 || element.getAttribute("contenteditable")) {
    if (element.getAttribute("disabled")) {
      return false;
    }
    return true;
  }

  const tabindex = parseInt(element.getAttribute("tabindex"), 10);
  if (!isNaN(tabindex) && tabindex >= 0) {
    return true;
  }

  return false;
}

const createFocusGuard = (position) => {
  return $(`<div class="${focusGuardClass}" data-position="${position}" tabindex="0" aria-hidden="true"></div>`);
};

const handleContainerFocus = ($container, $guard) => {
  const $reveal = $(".reveal:visible:last", $container);
  if ($reveal.length > 0) {
    handleContainerFocus($reveal, $guard);
    return;
  }

  const $nodes = $("*:visible", $container);
  let $target = null;

  if ($guard.data("position") === "start") {
    // Focus at the start guard, so focus the first focusable element after that
    for (let ind = 0; ind < $nodes.length; ind += 1) {
      if (!isFocusGuard($nodes[ind]) && isFocusable($nodes[ind])) {
        $target = $($nodes[ind]);
        break;
      }
    }
  } else {
    // Focus at the end guard, so focus the first focusable element after that
    for (let ind = $nodes.length - 1; ind >= 0; ind -= 1) {
      if (!isFocusGuard($nodes[ind]) && isFocusable($nodes[ind])) {
        $target = $($nodes[ind]);
        break;
      }
    }
  }

  if ($target) {
    $target.trigger("focus");
  } else {
    // If no focusable element was found, blur the guard focus
    $guard.blur();
  }
};

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

    // Once the final modal closes, remove the focus guards from the container
    $dialog.off("closed.zf.reveal.focusguard").on("closed.zf.reveal.focusguard", () => {
      $dialog.off("closed.zf.reveal.focusguard");

      // After the last dialog is closed, the tab guards should be removed.
      // Note that there may be multiple dialogs open on top of each other at
      // the same time.
      if ($(".reveal:visible", $container).length < 1) {
        $(`> .${focusGuardClass}`, $container).remove();
      }
    });

    // Check if the guards already exists due to some other dialog
    const $guards = $(`> .${focusGuardClass}`, $container);
    if ($guards.length > 0) {
      // Make sure the guards are the first and last element as there have
      // been changes in the DOM.
      $guards.each((_j, guard) => {
        const $guard = $(guard);
        if ($guard.data("position") === "start") {
          $container.prepend($guard);
        } else {
          $container.append($guard);
        }
      });

      return;
    }

    // Add guards at the start and end of the document and attach their focus
    // listeners
    const $startGuard = createFocusGuard("start");
    const $endGuard = createFocusGuard("end");

    $container.prepend($startGuard);
    $container.append($endGuard);

    $startGuard.on("focus", () => handleContainerFocus($container, $startGuard));
    $endGuard.on("focus", () => handleContainerFocus($container, $endGuard));
  });
};
