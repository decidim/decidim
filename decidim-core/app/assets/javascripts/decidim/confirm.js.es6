/**
 * A custom confirm dialog for Decidim based on Foundation reveals.
 *
 * Note that this needs to be loaded before the application JS in order for
 * it to gain control over the confirm events BEFORE rails-ujs is loaded.
 */
((exports) => {
  const { document } = exports;

  let TEMPLATE_HTML = null;

  class ConfirmDialog {
    constructor(sourceElement) {
      this.$modal = $(TEMPLATE_HTML);
      this.$source = sourceElement;
      this.$content = exports.$(".confirm-modal-content", this.$modal);
      this.$buttonConfirm = exports.$("[data-confirm-ok]", this.$modal);
      this.$buttonCancel = exports.$("[data-confirm-cancel]", this.$modal);

      // Avoid duplicate IDs and append the new modal to the body
      const titleId = `confirm-modal-title-${Math.random().toString(36).substring(7)}`;

      this.$modal.removeAttr("id");
      $("#confirm-modal-title", this.$modal).attr("id", titleId);
      this.$modal.attr("aria-labelledby", titleId);

      $("body").append(this.$modal);
      this.$modal.foundation();
    }

    confirm(message) {
      this.$content.html(message);

      this.$buttonConfirm.off("click");
      this.$buttonCancel.off("click");

      return new Promise((resolve) => {
        this.$buttonConfirm.on("click", (ev) => {
          ev.preventDefault();

          this.$modal.foundation("close");
          resolve(true);
          this.$source.focus();
        });
        this.$buttonCancel.on("click", (ev) => {
          ev.preventDefault();

          this.$modal.foundation("close");
          resolve(false);
          this.$source.focus();
        });

        this.$modal.foundation("open").on("closed.zf.reveal", () => {
          this.$modal.remove();
        });
      });
    }
  }

  exports.Decidim = exports.Decidim || {};
  exports.Decidim.ConfirmDialog = ConfirmDialog;

  // Override the default confirm dialog by Rails
  // See:
  // https://github.com/rails/rails/blob/fba1064153d8e2f4654df7762a7d3664b93e9fc8/actionview/app/assets/javascripts/rails-ujs/features/confirm.coffee
  //
  // There is apparently a better way coming in Rails 6:
  // https://github.com/rails/rails/commit/e9aa7ecdee0aa7bb4dcfa5046881bde2f1fe21cc#diff-e1aaa45200e9adcbcb8baf1c5375b5d1

  // Attach bindings BEFORE Rails adds its own bindings.
  document.addEventListener("rails:attachBindings", () => {
    const { Rails } = exports;
    const { fire, matches, stopEverything } = Rails;

    const allowAction = (ev, element) => {
      const message = exports.$(element).data("confirm");
      if (!message) {
        return true;
      }

      if (!fire(element, "confirm")) {
        return false;
      }

      if (TEMPLATE_HTML === null) {
        TEMPLATE_HTML = exports.$("#confirm-modal")[0].outerHTML;
        exports.$("#confirm-modal").remove();
      }

      const dialog = new ConfirmDialog(
        exports.$(element)
      );
      dialog.confirm(message).then((answer) => {
        const completed = fire(element, "confirm:complete", [answer]);
        if (answer && completed) {
          // Allow the event to propagate normally and re-dispatch it without
          // the confirm data attribute which the Rails internal method is
          // checking.
          exports.$(element).data("confirm", null);
          exports.$(element).removeAttr("data-confirm");

          // The submit button click events won't do anything if they are
          // dispatched as is. In these cases, just submit the underlying form.
          if (ev.type === "click" &&
            (
              exports.$(element).is('button[type="submit"]') ||
              exports.$(element).is('input[type="submit"]')
            )
          ) {
            exports.$(element).parents("form").submit();
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
        }
      });

      return false;
    };
    const handleConfirm = (ev, element) => {
      if (!allowAction(ev, element)) {
        stopEverything(ev);
      }
    };
    const getMatchingEventTarget = (ev, selector) => {
      let target = ev.target;
      while (!(!(target instanceof Element) || matches(target, selector))) {
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
      exports.$(Rails.formInputClickSelector).on("click.confirm", (ev) => {
        handleConfirm(ev, getMatchingEventTarget(ev, Rails.formInputClickSelector));
      });
    });
  });
})(window);
