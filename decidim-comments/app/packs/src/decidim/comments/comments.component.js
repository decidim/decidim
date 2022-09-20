/* eslint id-length: ["error", { "exceptions": ["$"] }] */
/* eslint max-lines: ["error", {"max": 350, "skipBlankLines": true}] */


/**
 * A plain Javascript component that handles the comments.
 *
 * @class
 * @augments Component
 */

// This is necessary for testing purposes
const $ = window.$;

import Rails from "@rails/ujs";

import { createCharacterCounter } from "src/decidim/input_character_counter"
import ExternalLink from "src/decidim/redesigned_external_link"
import updateExternalDomainLinks from "src/decidim/external_domain_warning"

export default class CommentsComponent {
  constructor($element, config) {
    this.$element = $element;
    this.commentableGid = config.commentableGid;
    this.commentsUrl = config.commentsUrl;
    this.rootDepth = config.rootDepth;
    this.order = config.order;
    this.lastCommentId = config.lastCommentId;
    this.pollingInterval = config.pollingInterval || 15000;
    this.singleComment = config.singleComment;
    this.toggleTranslations = config.toggleTranslations;
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
      if (!this.singleComment) {
        this._fetchComments();
      }

      $(".order-by__dropdown .is-submenu-item a", this.$element).on("click.decidim-comments", () => this._onInitOrder());
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
      this._stopPolling();

      $(".add-comment .opinion-toggle .button", this.$element).off("click.decidim-comments");
      $(".add-comment textarea", this.$element).off("input.decidim-comments");
      $(".order-by__dropdown .is-submenu-item a", this.$element).off("click.decidim-comments");
      $(".add-comment form", this.$element).off("submit.decidim-comments");
      $(".add-comment textarea", this.$element).each((_i, el) => el.removeEventListener("emoji.added", this._onTextInput));
    }
  }

  /**
   * Adds a new thread to the comments section.
   * @public
   * @param {String} threadHtml - The HTML content for the thread.
   * @param {Boolean} fromCurrentUser - A boolean indicating whether the user
   *   herself was the author of the new thread. Defaults to false.
   * @returns {Void} - Returns nothing
   */
  addThread(threadHtml, fromCurrentUser = false) {
    const $parent = $(".comments:first", this.$element);
    const $comment = $(threadHtml);
    const $threads = $(".comment-threads", this.$element);
    this._addComment($threads, $comment);
    this._finalizeCommentCreation($parent, fromCurrentUser);
  }

  /**
   * Adds a new reply to an existing comment.
   * @public
   * @param {Number} commentId - The ID of the comment for which to add the
   *   reply to.
   * @param {String} replyHtml - The HTML content for the reply.
   * @param {Boolean} fromCurrentUser - A boolean indicating whether the user
   *   herself was the author of the new reply. Defaults to false.
   * @returns {Void} - Returns nothing
   */
  addReply(commentId, replyHtml, fromCurrentUser = false) {
    const $parent = $(`#comment_${commentId}`);
    const $comment = $(replyHtml);
    const $replies = $(`#comment-${commentId}-replies`);
    this._addComment($replies, $comment);
    $replies.siblings(".comment__additionalreply").removeClass("hide");
    this._finalizeCommentCreation($parent, fromCurrentUser);
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
      const $text = $("textarea", $form);

      $opinionButtons.on("click.decidim-comments", this._onToggleOpinion);
      $text.on("input.decidim-comments", this._onTextInput);

      $(document).trigger("attach-mentions-element", [$text.get(0)]);

      $form.on("submit.decidim-comments", () => {
        const $submit = $("button[type='submit']", $form);

        $submit.attr("disabled", "disabled");
        this._stopPolling();
      });

      if ($text.length && $text.get(0) !== null) {
        // Attach event to the DOM node, instead of the jQuery object
        $text.get(0).addEventListener("emoji.added", this._onTextInput);
      }
    });
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
    createCharacterCounter($(".add-comment textarea", $container));
    $container.find('a[target="_blank"]').each((_i, elem) => new ExternalLink(elem));
    updateExternalDomainLinks($container)
  }

  /**
   * Finalizes the new comment creation after the comment adding finishes
   * successfully.
   * @private
   * @param {jQuery} $parent - The parent comment element to finalize.
   * @param {Boolean} fromCurrentUser - A boolean indicating whether the user
   *   herself was the author of the new comment.
   * @returns {Void} - Returns nothing
   */
  _finalizeCommentCreation($parent, fromCurrentUser) {
    if (fromCurrentUser) {
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
      this._fetchComments();
    }, this.pollingInterval);
  }

  /**
   * Sends an ajax request based on current
   * params to get comments for the component
   * @private
   * @returns {Void} - Returns nothing
   */
  _fetchComments() {
    $(".add-comment textarea", this.$element).prop("disabled", true);
    Rails.ajax({
      url: this.commentsUrl,
      type: "GET",
      data: new URLSearchParams({
        "commentable_gid": this.commentableGid,
        "root_depth": this.rootDepth,
        "order": this.order,
        "after": this.lastCommentId,
        ...(this.toggleTranslations && { "toggle_translations": this.toggleTranslations }),
        ...(this.lastCommentId && { "after": this.lastCommentId })
      }),
      success: () => {
        $(".add-comment textarea", this.$element).prop("disabled", false);
        this._pollComments();
      }
    });
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

  /**
   * Sets the loading comments element visible in the view.
   * @private
   * @returns {Void} - Returns nothing
   */
  _setLoading() {
    const $container = $("> .comments-container", this.$element);
    $("> .comments", $container).addClass("hide");
    $("> .loading-comments", $container).removeClass("hide");
  }

  /**
   * Event listener for the ordering links.
   * @private
   * @returns {Void} - Returns nothing
   */
  _onInitOrder() {
    this._stopPolling();
    this._setLoading();
  }

  /**
   * Event listener for the opinion toggle buttons.
   * @private
   * @param {Event} ev - The event object.
   * @returns {Void} - Returns nothing
   */
  _onToggleOpinion(ev) {
    let $btn = $(ev.target);
    if (!$btn.is(".button")) {
      $btn = $btn.parents(".button");
    }

    const $add = $btn.closest(".add-comment");
    const $form = $("form", $add);
    const $opinionButtons = $(".opinion-toggle .button", $add);
    const $selectedState = $(".opinion-toggle .selected-state", $add);
    const $alignment = $(".alignment-input", $form);

    $opinionButtons.removeClass("is-active").attr("aria-pressed", "false");
    $btn.addClass("is-active").attr("aria-pressed", "true");

    if ($btn.is(".opinion-toggle--ok")) {
      $alignment.val(1);
    } else if ($btn.is(".opinion-toggle--meh")) {
      $alignment.val(0);
    } else if ($btn.is(".opinion-toggle--ko")) {
      $alignment.val(-1);
    }

    // Announce the selected state for the screen reader
    $selectedState.text($btn.data("selected-label"));
  }

  /**
   * Event listener for the comment field text input.
   * @private
   * @param {Event} ev - The event object.
   * @returns {Void} - Returns nothing
   */
  _onTextInput(ev) {
    const $text = $(ev.target);
    const $add = $text.closest(".add-comment");
    const $form = $("form", $add);
    const $submit = $("button[type='submit']", $form);

    if ($text.val().length > 0) {
      $submit.removeAttr("disabled");
    } else {
      $submit.attr("disabled", "disabled");
    }
  }
}
