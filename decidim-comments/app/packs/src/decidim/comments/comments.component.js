/* eslint id-length: ["error", { "exceptions": ["$"] }] */
/* eslint max-lines: ["error", {"max": 350, "skipBlankLines": true}] */
/* eslint-disable max-lines */

/**
 * A plain JavaScript component that handles the comments.
 *
 * @class
 * @augments Component
 */

// This is necessary for testing purposes
const $ = window.$;

import changeReportFormBehavior from "src/decidim/change_report_form_behavior";
import { initializeCommentsDropdown } from "../../decidim/comments/comments_dropdown";

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

    this._onTextInput = this._onTextInput.bind(this);
    this._onToggleOpinion = this._onToggleOpinion.bind(this);
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
        $(".add-comment textarea", this.$element).prop("disabled", true);
        this._fetchComments(() => {
          $(".add-comment textarea", this.$element).prop("disabled", false);
        });
      }
      this._initializeSortDropdown();
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
      this.lastCommentId = null;

      $(".add-comment [data-opinion-toggle] button", this.$element).off("click.decidim-comments");
      $(".add-comment textarea", this.$element).off("input.decidim-comments");
      $(".add-comment form", this.$element).off("submit.decidim-comments");
      $(".add-comment textarea", this.$element).each((_i, el) => el.removeEventListener("emoji.added", this._onTextInput));
    }
  }

  /**
   * Adds a new thread to the comments section.
   * If the layout is a two-column layout, the comment is added to either
   * the "in favor" or "against" column based on the alignment provided.
   * If the layout is a single column or on a mobile screen,
   * the comment is added to the general comment thread with interleaved ordering.
   *
   * @public
   * @param {String} threadHtml - The HTML content for the thread to be added.
   * @param {Number|null} alignment - Specifies the alignment of the comment.
   *   If -1, the comment is added to the "against" column.
   *   If 1, the comment is added to the "in favor" column.
   *   If null or if on a mobile screen, the comment is added to the general thread.
   * @param {Boolean} fromCurrentUser - A boolean indicating whether the user
   *   is the author of the new thread. Defaults to false.
   * @returns {Void} - Does not return a value.
   */
  addThread(threadHtml, alignment = null, fromCurrentUser = false) {
    const $comment = $(threadHtml);
    let $parent = null;

    const $commentsContainer = $(".comments-two-columns", this.$element);
    const isTwoColumnsLayout = $commentsContainer.length > 0;
    const isMobileScreen = window.innerWidth < 768;

    if (isTwoColumnsLayout && !isMobileScreen) {
      const $inFavorColumn = $(".comments-section__in-favor", this.$element);
      const $againstColumn = $(".comments-section__against", this.$element);

      if (alignment === 1 && $inFavorColumn.length > 0) {
        $parent = $inFavorColumn;
      } else if (alignment === -1 && $againstColumn.length > 0) {
        $parent = $againstColumn;
      } else {
        $parent = $(".comment-threads", this.$element);
      }
    } else {
      $parent = $(".comment-threads", this.$element);
    }

    this._addComment($parent, $comment);
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
    $replies.addClass("comment-reply");
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
      const $opinionButtons = $("[data-opinion-toggle] button", $add);
      const $text = $("textarea", $form);

      $opinionButtons.on("click.decidim-comments", this._onToggleOpinion);
      $text.on("input.decidim-comments", this._onTextInput);

      $(document).trigger("attach-mentions-element", [$text.get(0)]);

      $form.on("submit.decidim-comments", () => {
        const $submit = $("button[type='submit']", $form);

        $submit.attr("disabled", "disabled");
        this._stopPolling();
      });

      document.querySelectorAll(".new_report").forEach((container) => changeReportFormBehavior(container));

      const $dropdown = $add.find("[data-comments-dropdown]");
      if ($dropdown.length > 0) {
        initializeCommentsDropdown($dropdown[0]);
      }

      document.querySelectorAll(".new_report").forEach((container) => changeReportFormBehavior(container))

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

    this._initializeComments($container);
    document.dispatchEvent(new CustomEvent("comments:loaded", { detail: { commentsIds: [this.lastCommentId] } }));
  }

  /**
   * Finalizes the new comment creation after the comment adding finishes
   * successfully.
   * @private
   * @param {jQuery} $parent - The parent element representing where the comment
   *  was added.
   * @param {Boolean} fromCurrentUser - A boolean indicating whether the user
   *   herself was the author of the new comment.
   * @returns {Void} - Returns nothing
   */
  _finalizeCommentCreation($parent, fromCurrentUser) {
    if (fromCurrentUser) {
      const $addCommentForms = $(".add-comment", this.$element);

      $addCommentForms.each((_i, form) => {
        const $form = $(form);
        const $textarea = $form.find("textarea");

        $textarea.val("");

        const characterCounter = $textarea.data("remaining-characters-counter");
        if (characterCounter) {
          characterCounter.handleInput();
          characterCounter.updateStatus();
        }
      });
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

  reloadAllComments() {
    this._setLoading();
    this._fetchComments();
  }

  /**
   * Sends an ajax request based on current
   * params to get comments for the component
   * @private
   * @param {Function} successCallback A callback that is called after a
   *   successful fetch
   * @returns {Void} - Returns nothing
   */
  _fetchComments(successCallback = null) {
    Rails.ajax({
      url: this.commentsUrl,
      type: "GET",
      data: new URLSearchParams({
        "commentable_gid": this.commentableGid,
        "root_depth": this.rootDepth,
        "order": this.order,
        // From here, the rest of properties are optional
        ...(this.toggleTranslations && { "toggle_translations": this.toggleTranslations }),
        ...(this.lastCommentId && { "after": this.lastCommentId })
      }),
      success: () => {
        if (successCallback) {
          successCallback();
        }
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
    const $container = $("> #comments", this.$element);
    $("> .comments", $container).addClass("hidden");
    $("> .loading-comments", $container).removeClass("hidden");
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
   * Updates the state of the submit button based on input text and opinion selection.
   *
   * @param {Object} params - The parameters for updating the submit button state.
   * @param {jQuery} params.$form - The form element.
   * @param {boolean} params.isTextNotEmpty - Whether the text input is not empty.
   * @param {boolean} params.isTwoColumnsLayout - Whether the layout is two-column.
   * @param {boolean} params.isOpinionSelected - Whether an opinion (for/against) has been selected.
   * @returns {void} - Does not return a value.
   * @private
   */
  _updateSubmitButtonState({ $form, isTextNotEmpty, isTwoColumnsLayout, isOpinionSelected }) {
    const $submit = $("button[type='submit']", $form);
    if (isTextNotEmpty && (!isTwoColumnsLayout || isOpinionSelected)) {
      $submit.removeAttr("disabled");
    } else {
      $submit.attr("disabled", "disabled");
    }
  }

  /**
   * Prepares parameters for updating the submit button state.
   *
   * @param {jQuery} $form - The form element.
   * @returns {Object} - Returns an object with necessary parameters.
   * @private
   */
  _prepareSubmitButtonStateParams($form) {
    const $opinionButtons = $("[data-opinion-toggle] button", $form.closest(".add-comment"));
    const isTwoColumnsLayout = $(".comments-two-columns", this.$element).length > 0;
    const isOpinionSelected = $opinionButtons.filter("[aria-pressed='true']").length > 0;
    const isTextNotEmpty = $("textarea", $form).val().length > 0;

    return {
      $form,
      isTextNotEmpty,
      isTwoColumnsLayout,
      isOpinionSelected
    };
  }

  /**
   * Event listener for the opinion toggle buttons.
   * @private
   * @param {Event} ev - The event object.
   * @returns {Void} - Returns nothing
   */
  _onToggleOpinion(ev) {
    let $btn = $(ev.target);
    if (!$btn.is("button")) {
      $btn = $btn.parents("button");
    }

    const $add = $btn.closest(".add-comment");
    const $form = $("form", $add);
    const $opinionButtons = $("[data-opinion-toggle] button", $add);
    const $selectedState = $("[data-opinion-toggle] .selected-state", $add);
    const $alignment = $(".alignment-input", $form);

    $opinionButtons.removeClass("is-active").attr("aria-pressed", "false");
    $btn.addClass("is-active").attr("aria-pressed", "true");
    $btn.css("fontWeight","bold");

    if ($btn.data("toggleOk")) {
      $alignment.val(1);
    } else if ($btn.data("toggleMeh")) {
      $alignment.val(0);
    } else if ($btn.data("toggleKo")) {
      $alignment.val(-1);
    }

    // Announce the selected state for the screen reader
    $selectedState.text($btn.data("selected-label"));

    this._updateSubmitButtonState(this._prepareSubmitButtonStateParams($form));
  }

  /**
   * Event listener for the comment field text input.
   * @private
   * @param {{target: (*|jQuery|HTMLElement)}} ev - The event object.
   * @returns {Void} - Returns nothing
   */
  _onTextInput(ev) {
    const $text = $(ev.target);
    const $add = $text.closest(".add-comment");
    const $form = $("form", $add);

    this._updateSubmitButtonState(this._prepareSubmitButtonStateParams($form));
  }

  /**
  * Adds the behaviour for the drop down order section within comments.
  * @private
  * @returns {Void} - Returns nothing
  */
  _initializeSortDropdown() {
    const desktopOrderSelect = document.querySelector("[data-desktop-order-comment-select]");
    const mobileOrderSelect = document.querySelector("[data-mobile-order-comment-select]");

    if (!desktopOrderSelect && !mobileOrderSelect) {
      return;
    }

    desktopOrderSelect.style.borderColor = "black";
    mobileOrderSelect.style.borderColor = "black";

    desktopOrderSelect.addEventListener("change", function(event) {
      const selectedOption = desktopOrderSelect.querySelector(`[value=${event.target.value}]`);
      const orderUrl = selectedOption.dataset.orderCommentUrl;

      Rails.ajax({
        url: orderUrl,
        type: "GET",
        error: (data) => (console.error(data))
      });
    });

    mobileOrderSelect.addEventListener("change", function(event) {
      const selectedOption = mobileOrderSelect.querySelector(`[value=${event.target.value}]`);
      const orderUrl = selectedOption.dataset.orderCommentUrl;

      Rails.ajax({
        url: orderUrl,
        type: "GET",
        error: (data) => (console.error(data))
      });
    });
  }
}
/* eslint-enable max-lines */
