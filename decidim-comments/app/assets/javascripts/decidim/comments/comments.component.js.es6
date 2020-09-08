/**
 * A plain Javascript component that handles the comments.
 *
 * @class
 * @augments Component
 */
((exports) => {
  const $ = exports.$; // eslint-disable-line

  class CommentsComponent {
    constructor($element) {
      this.$element = $element;
      this.id = this.$element.attr("id") || this._getUID();
      this.mounted = false;
    }

    /**
     * Handles the logic for mounting the component
     * @public
     * @returns {Void} - Returns nothing
     */
    mountComponent() {
      if (this.$element.length > 0 && !this.mounted) {
        this.mounted = true;

        $(".add-comment", this.$element).each((_i, el) => {
          const $add = $(el);
          const $form = $("form", $add);
          const $opinionButtons = $(".opinion-toggle .button", $add);
          const $alignment = $(".alignment-input", $form);
          const $text = $("textarea", $form);
          const $submit = $("button[type='submit']", $form);

          $opinionButtons.on("click.decidim-comments", (ev) => {
            let $btn = $(ev.target);
            if (!$btn.is(".button")) {
              $btn = $btn.parents(".button");
            }

            $opinionButtons.removeClass("is-active");
            $btn.addClass("is-active");

            if ($btn.is(".opinion-toggle--ok")) {
              $alignment.val(1);
            } else if ($btn.is(".opinion-toggle--meh")) {
              $alignment.val(0);
            } else if ($btn.is(".opinion-toggle--ko")) {
              $alignment.val(-1);
            }
          });

          $text.on("input.decidim-comments", () => {
            if ($text.val().length > 0) {
              $submit.removeAttr("disabled");
            } else {
              $submit.attr("disabled", "disabled");
            }
          })
        });
      }
    }

    /**
     * Handles the logic for unmounting the component
     * @public
     * @returns {Void} - Returns nothing
     */
    unmountComponent() {
      if (this.mounted) {
        this.mounted = false;

        $(".add-comment .opinion-toggle .button", this.$element).off("click.decidim-comments");
        $(".add-comment textarea", this.$element).off("input.decidim-comments");
      }
    }

    /**
     * Generates a unique identifier for the form.
     * @private
     * @returns {String} - Returns a unique identifier
     */
    _getUID() {
      return `comments-${new Date().setUTCMilliseconds()}-${Math.floor(Math.random() * 10000000)}`;
    }
  }

  exports.Decidim = exports.Decidim || {};
  exports.Decidim.CommentsComponent = CommentsComponent;

  $(() => {
    $("[data-decidim-comments]").each((_i, el) => {
      const comments = new CommentsComponent($(el));
      comments.mountComponent();
    })
  });
})(window);
