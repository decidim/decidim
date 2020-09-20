/**
 * A plain Javascript component that handles the comments.
 *
 * @class
 * @augments Component
 */
((exports) => {
  const $ = exports.$; // eslint-disable-line

  class CommentsComponent {
    constructor($element, config) {
      this.$element = $element;
      this.commentableGid = config.commentableGid;
      this.commentsUrl = config.commentsUrl;
      this.rootDepth = config.rootDepth;
      this.lastCommentId = config.lastCommentId;
      this.pollingInterval = config.pollingInterval || 15000;
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
        this._initializeComments(this.$element);
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
     * Adds a new thread to the comments section.
     * @public
     * @param {String} threadHtml - The HTML content for the thread.
     * @returns {Void} - Returns nothing
     */
    addThread(threadHtml) {
      const $parent = $(".comments:first", this.$element);
      const $comment = $(threadHtml);
      const $threads = $(".comment-threads", this.$element);
      this._addComment($threads, $comment);
      this._finalizeCommentCreation($parent);
    }

    /**
     * Adds a new reply to an existing comment.
     * @public
     * @param {Number} commentId - The ID of the comment for which to add the
     *   reply to.
     * @param {String} replyHtml - The HTML content for the reply.
     * @returns {Void} - Returns nothing
     */
    addReply(commentId, replyHtml) {
      const $parent = $(`#comment_${commentId}`);
      const $comment = $(replyHtml);
      const $replies = $(`#comment-${commentId}-replies`);
      this._addComment($replies, $comment);
      $replies.siblings(".comment__additionalreply").removeClass("hide");
      this._finalizeCommentCreation($parent);
    }

    /**
     * Generates a unique identifier for the form.
     * @private
     * @returns {String} - Returns a unique identifier
     */
    _getUID() {
      return `comments-${new Date().setUTCMilliseconds()}-${Math.floor(Math.random() * 10000000)}`;
    }

    /**
     * Initializes the comments for the given parent element.
     * @private
     * @param {jQuery} $parent The parent element to initialize.
     * @returns {Void} - Returns nothing
     */
    _initializeComments($parent) {
      $(".add-comment", $parent).each((_i, el) => {
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
        });

        $form.on("submit", () => {
          $submit.attr("disabled", "disabled");
          this._stopPolling();
        });
      });

      this._pollComments();
    }

    /**
     * Adds the given comment element to the given target element and
     * initializes it.
     * @private
     * @param {jQuery} $target - The target element to add the comment to.
     * @param {jQuery} $container - The comment container element to add.
     * @returns {Void} - Returns nothing
     */
    _addComment($target, $container) {
      let $comment = $(".comment", $container);
      if ($comment.length < 1) {
        // In case of a reply
        $comment = $container;
      }
      this.lastCommentId = parseInt($comment.data("comment-id"), 10);

      $target.append($container);
      $container.foundation();
      this._initializeComments($container);
      if (exports.Decidim.createCharacterCounter) {
        exports.Decidim.createCharacterCounter($(".add-comment textarea", $container));
      }
    }

    /**
     * Finalizes the new comment creation after the comment adding finishes
     * successfully.
     * @private
     * @param {jQuery} $parent - The parent comment element to finalize.
     * @returns {Void} - Returns nothing
     */
    _finalizeCommentCreation($parent) {
      const $add = $("> .add-comment", $parent);
      const $text = $("textarea", $add);
      const characterCounter = $text.data("remaining-characters-counter");
      $text.val("");
      if (characterCounter) {
        characterCounter.updateStatus();
      }
      if (!$add.parent().is(".comments")) {
        $add.addClass("hide");
      }

      // Restart the polling
      this._pollComments();
    }

    /**
     * Sets a timeout to poll new comments.
     * @private
     * @returns {Void} - Returns nothing
     */
    _pollComments() {
      this._stopPolling();

      this.pollTimeout = setTimeout(() => {
        $.ajax({
          url: this.commentsUrl,
          method: "GET",
          contentType: "application/javascript",
          data: {
            "commentable_gid": this.commentableGid,
            "root_depth": this.rootDepth,
            after: this.lastCommentId
          }
        }).done(() => {
          this._pollComments();
        });
      }, this.pollingInterval);
    }

    /**
     * Stops polling for new comments.
     * @private
     * @returns {Void} - Returns nothing
     */
    _stopPolling() {
      if (this.pollTimeout) {
        clearTimeout(this.pollTimeout);
      }
    }
  }

  exports.Decidim = exports.Decidim || {};
  exports.Decidim.CommentsComponent = CommentsComponent;

  $(() => {
    $("[data-decidim-comments]").each((_i, el) => {
      const $el = $(el);
      const comments = new CommentsComponent($el, $el.data("decidim-comments"));
      comments.mountComponent();

      $(el).data("comments", comments);
    });
  });
})(window);
