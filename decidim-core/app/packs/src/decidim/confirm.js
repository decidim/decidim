import icon from "src/decidim/icon"

/**
 * A custom confirm dialog for Decidim based on Foundation reveals.
 *
 * Note that this needs to be loaded before the application JS in order for
 * it to gain control over the confirm events BEFORE rails-ujs is loaded.
 */

const { Rails } = window;

class ConfirmDialog {
  constructor(sourceElement) {
    this.$modal = $("#confirm-modal");
    if (sourceElement) {
      this.$source = $(sourceElement);
    }
    this.$content = $("[data-confirm-modal-content]", this.$modal);
    this.$title = $("[data-dialog-title]", this.$modal);
    this.$iconContainer = $(".confirm-modal-icon", this.$modal);
    this.$buttonConfirm = $("[data-confirm-ok]", this.$modal);
    this.$buttonCancel = $("[data-confirm-cancel]", this.$modal);

    window.Decidim.currentDialogs["confirm-modal"].open()
  }

  confirm(message, title, iconName) {
    if (title) {
      this.$title.html(title);
    }
    if (iconName) {
      this.$iconContainer.html(icon(iconName, { width: null, height: null }));
    }

    this.$content.html(message);

    this.$buttonConfirm.off("click");
    this.$buttonCancel.off("click");

    return new Promise((resolve) => {

      this.$buttonConfirm.on("click", (ev) => {
        ev.preventDefault();

        this.close(() => resolve(true));
      });

      this.$buttonCancel.on("click", (ev) => {
        ev.preventDefault();

        this.close(() => resolve(false));
      });
    });
  }

  close(afterClose) {
    window.Decidim.currentDialogs["confirm-modal"].close()
    afterClose();
    if (this.$source) {
      this.$source.focus();
    }
  }
}

const runConfirm = (message, sourceElement = null, opts = {}) => new Promise((resolve) => {
  const dialog = new ConfirmDialog(sourceElement);
  dialog.confirm(message, opts.title, opts.iconName).then((answer) => {
    let completed = true;
    if (sourceElement) {
      completed = Rails.fire(sourceElement, "confirm:complete", [answer]);
    }
    resolve(answer && completed);
  });
});

// Override the default confirm dialog by Rails
// See:
// https://github.com/rails/rails/blob/fba1064153d8e2f4654df7762a7d3664b93e9fc8/actionview/app/assets/javascripts/rails-ujs/features/confirm.coffee
//
// There is apparently a better way coming in Rails 6:
// https://github.com/rails/rails/commit/e9aa7ecdee0aa7bb4dcfa5046881bde2f1fe21cc#diff-e1aaa45200e9adcbcb8baf1c5375b5d1
//
// The old approach is broken according to https://github.com/rails/rails/issues/36686#issuecomment-514213323
// so for the moment this needs to be executed **before** Rails.start()
const allowAction = (ev, element) => {
  const message = $(element).data("confirm");
  const opts = {
    title: $(element).data("confirm-title"),
    iconName: $(element).data("confirm-icon")
  };
  if (!message) {
    return true;
  }

  if (!Rails.fire(element, "confirm")) {
    return false;
  }

  runConfirm(message, element, opts).then((answer) => {
    if (!answer) {
      return;
    }

    // Allow the event to propagate normally and re-dispatch it without
    // the confirm data attribute which the Rails internal method is
    // checking.
    $(element).data("confirm", null);
    $(element).removeAttr("data-confirm");
    $(element).data("confirm-title", null);
    $(element).removeAttr("data-confirm-title");
    $(element).data("confirm-icon", null);
    $(element).removeAttr("data-confirm-icon");

    // The submit button click events will not do anything if they are
    // dispatched as is. In these cases, just submit the underlying form.
    if (ev.type === "click" &&
      (
        $(element).is('button[type="submit"]') ||
        $(element).is('input[type="submit"]')
      )
    ) {
      $(element).parents("form").submit();
    } else {
      let origEv = ev.originalEvent || ev;
      let newEv = origEv;
      if (typeof Event === "function") {
        // Clone the event because otherwise some click events may not
        // work properly when re-dispatched.
        newEv = new origEv.constructor(origEv.type, origEv);
      }
      ev.target.dispatchEvent(newEv);
    }
  });

  return false;
};
const handleConfirm = (ev, element) => {
  if (!allowAction(ev, element)) {
    Rails.stopEverything(ev);
  }
};
const getMatchingEventTarget = (ev, selector) => {
  let target = ev.target;
  while (!(!(target instanceof Element) || Rails.matches(target, selector))) {
    target = target.parentNode;
  }

  if (target instanceof Element) {
    return target;
  }

  return null;
};
const handleDocumentEvent = (ev, matchSelectors) => {
  return matchSelectors.some((currentSelector) => {
    let target = getMatchingEventTarget(ev, currentSelector);
    if (target === null) {
      return false;
    }

    handleConfirm(ev, target);
    return true;
  });
};

// Note that this needs to be run **before** Rails.start()
export const initializeConfirm = () => {
  document.addEventListener("click", (ev) => {
    return handleDocumentEvent(ev, [
      Rails.linkClickSelector,
      Rails.buttonClickSelector,
      Rails.formInputClickSelector
    ]);
  });
  document.addEventListener("change", (ev) => {
    return handleDocumentEvent(ev, [Rails.inputChangeSelector]);
  });
  document.addEventListener("submit", (ev) => {
    return handleDocumentEvent(ev, [Rails.formSubmitSelector]);
  });

  // This is needed for the confirm dialog to work with Foundation Abide.
  // Abide registers its own submit click listeners since Foundation 5.6.x
  // which will be handled before the document listeners above. This would
  // break the custom confirm functionality when used with Foundation Abide.
  document.addEventListener("DOMContentLoaded", function() {
    $(Rails.formInputClickSelector).on("click.confirm", (ev) => {
      handleConfirm(ev, getMatchingEventTarget(ev, Rails.formInputClickSelector));
    });
  });
};

export default runConfirm;
