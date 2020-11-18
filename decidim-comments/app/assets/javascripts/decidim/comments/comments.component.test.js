/* eslint-disable id-length, max-lines */
/* global spyOn, jest */
const $ = require("jquery");

// Ability to spy on the jQuery methods inside the component in order to test
// the sub-elements correctly. Needs to be defined before the modules are loaded
// in order for them to define the $ variable correctly.
window.$ = jest.fn().mockImplementation((...args) => $(...args));
window.$.ajax = jest.fn().mockImplementation((...args) => $.ajax(...args));

// Quill is expected by the input character counter
window.Quill = require("../../../../../../decidim-core/vendor/assets/javascripts/quill.min.js");

// Fake timers for testing polling
jest.useFakeTimers();

require("../../../../../../decidim-core/app/assets/javascripts/decidim/input_character_counter.js.es6");
require("./comments.component.js.es6");

const { Decidim: { CommentsComponent, createCharacterCounter } } = window;

// Create a dummy foundation jQuery method for the comments component to call
$.fn.foundation = () => {};

describe("CommentsComponent", () => {
  const selector = "#comments-for-Dummy-123";
  let subject = null;
  let $doc = null;
  let $container = null;
  let addComment = null;
  let orderLinks = null;
  let allToggles = null;
  let allTextareas = null;
  let allForms = null;

  const spyOnAddComment = (methodToSpy) => {
    addComment.each((i) => {
      addComment[i].$ = $(addComment[i]);
      addComment[i].opinionToggles = $(".opinion-toggle .button", addComment[i].$);
      addComment[i].commentForm = $("form", addComment[i].$);
      addComment[i].commentTextarea = $("textarea", addComment[i].commentForm);

      if (methodToSpy) {
        spyOn(addComment[i].opinionToggles, methodToSpy);
        spyOn(addComment[i].commentForm, methodToSpy);
        spyOn(addComment[i].commentTextarea, methodToSpy);
      }
    });

    spyOn(window, "$").mockImplementation((...args) => {
      const jqSelector = args[0];
      const parent = args[1];

      if (jqSelector === document) {
        return $doc;
      } else if (jqSelector === ".order-by__dropdown .is-submenu-item a" && parent.is(subject.$element)) {
        return orderLinks;
      } else if (jqSelector === ".add-comment" && parent.is(subject.$element)) {
        return addComment;
      } else if (jqSelector === ".add-comment .opinion-toggle .button" && parent.is(subject.$element)) {
        return allToggles;
      } else if (jqSelector === ".add-comment textarea" && parent.is(subject.$element)) {
        return allTextareas;
      } else if (jqSelector === ".add-comment form" && parent.is(subject.$element)) {
        return allForms;
      }
      const addCommentsArray = addComment.toArray();
      for (let i = 0; i < addCommentsArray.length; i += 1) {
        if (jqSelector === ".opinion-toggle .button" && parent.is(addCommentsArray[i].$)) {
          return addCommentsArray[i].opinionToggles;
        } else if (jqSelector === "form" && parent.is(addCommentsArray[i].$)) {
          return addCommentsArray[i].commentForm;
        } else if (jqSelector === "textarea" && parent.is(addCommentsArray[i].commentForm)) {
          return addCommentsArray[i].commentTextarea;
        }
      }
      return $(...args);
    });
  }

  const generateCommentForm = (modelName, modelId) => {
    return `
      <form class="new_comment" id="new_comment_for_${modelName}_${modelId}" action="/comments?order=older" accept-charset="UTF-8" data-remote="true" method="post">
        <input name="utf8" type="hidden" value="✓" />
        <input type="hidden" value="commentable-gid" name="comment[commentable_gid]" />
        <input class="alignment-input" type="hidden" value="0" name="comment[alignment]" />
        <div class="field">
          <label for="add-comment-${modelName}-${modelId}-user-group-id">
            Comment as
          </label>
          <select id="add-comment-${modelName}-${modelId}-user-group-id" name="comment[user_group_id]">
            <option value="">Dwain Oberbrunner</option>
            <option value="4">Schmidt, Adams and Cassin</option>
          </select>
        </div>

        <div class="field">
          <label class="show-for-sr" for="add-comment-${modelName}-${modelId}">
            Comment
          </label>
          <div class="hashtags__container">
            <label for="comment_body">
              Body
              <span
                  title=""
                  data-tooltip="true"
                  data-disable-hover="false"
                  data-keep-on-hover="true"
                  aria-haspopup="true"
                  class="label-required has-tip"
              >
                <span aria-hidden="true">*</span><span class="show-for-sr">Required field</span>
              </span>
              <textarea
                required="required"
                maxlength="1000"
                id="add-comment-Comment-${modelId}"
                rows="4"
                placeholder="What do you think about this?"
                data-tribute="true"
                data-remaining-characters="#add-comment-${modelName}-${modelId}-remaining-characters"
                name="comment[body]"
              ></textarea>
              <span class="form-error">There's an error in this field.</span>
            </label>
          </div>
          <button type="submit" class="button button--sc" disabled="disabled">Send</button>
          <span id="add-comment-${modelName}-${modelId}-remaining-characters" class="remaining-character-count">1000 characters left</span>
        </div>
      </form>
    `;
  };

  const generateSingleComment = (commentId, content, replies = "") => {
    return `
      <div id="comment_${commentId}" class="comment comment--nested" data-comment-id="${commentId}">
        <div class="comment__header">
          <div class="author-data">
            <div class="author-data__main">
              <div class="author author--inline">
                <a href="/profiles/eusebio_rempel">
                  <span class="author__avatar">
                    <img alt="Avatar" src="/assets/decidim/default-avatar-123.svg" />
                  </span>
                  <span
                    class="author__name m-none has-tip"
                    data-position="top"
                    data-show-on="medium"
                    data-alignment="center"
                    data-click-open="false"
                    data-keep-on-hover="true"
                    data-allow-html="true"
                    data-template-classes="light expanded"
                    data-tip-text="Tip text"
                    title=""
                  >Dwain Oberbrunner</span>
                </a>
              </div>

              <span>
                <time datetime="2020-09-28T17:15:08Z">28/09/2020 17:15</time>
              </span>
            </div>
            <div class="author-data__extra">
                <button type="button" class="link-alt" data-open="flagModalComment${commentId}" title="Report inappropriate content" aria-controls="flagModalComment${commentId}" aria-haspopup="true" tabindex="0">
                  <svg role="none presentation" aria-hidden="true" class="icon--flag icon icon--small">
                    <title></title>
                    <use role="none presentation" href="/assets/decidim/icons-123.svg#icon-flag"></use>
                  </svg>
                  <span class="show-for-sr">Report inappropriate content</span>
                </button>

                <a title="Get link to single comment" href="/path/to/dummy/123?commentId=${commentId}#comment_${commentId}">
                  <span class="show-for-sr">Get link to single comment</span>
                  <svg role="none presentation" class="icon--link-intact icon icon--small">
                    <title></title>
                    <use role="none presentation" href="/assets/decidim/icons-123.svg#icon-link-intact"></use>
                  </svg>
                </a>
            </div>
          </div>
        </div>
        <div class="comment__content">
          <p>${content}</p>
        </div>
        <div class="comment__footer">
            <div class="comment__actions">
              <button class="comment__reply muted-link" aria-controls="comment${commentId}-reply" data-toggle="comment${commentId}-reply" aria-expanded="true">
                <svg role="none presentation" class="icon--pencil icon icon--small">
                  <title></title>
                  <use role="none presentation" href="/assets/decidim/icons-123.svg#icon-pencil"></use>
                </svg>
                &nbsp;Reply
              </button>
            </div>

            <div class="comment__votes">
              <form class="button_to" method="post" action="/comments/${commentId}/votes?weight=1" data-remote="true">
                <button class="comment__votes--up" title="I agree with this comment" type="submit">
                  <span class="show-for-sr">I agree with this comment</span>
                  <svg role="none presentation" class="icon--chevron-top icon icon--small">
                    <title></title>
                    <use role="none presentation" href="/assets/decidim/icons-123.svg#icon-chevron-top"></use>
                  </svg>
                  <span class="comment__votes--count">0</span>
                </button>
                <input type="hidden" name="authenticity_token" value="xyz123" />
              </form>

              <form class="button_to" method="post" action="/comments/${commentId}/votes?weight=-1" data-remote="true">
                <button class="comment__votes--down" title="I disagree with this comment" type="submit">
                  <span class="show-for-sr">I disagree with this comment</span>
                  <svg role="none presentation" class="icon--chevron-bottom icon icon--small">
                    <title></title>
                    <use role="none presentation" href="/assets/decidim/icons-123.svg#icon-chevron-bottom"></use>
                  </svg>
                  <span class="comment__votes--count">0</span>
                </button>
                <input type="hidden" name="authenticity_token" value="xyz123" />
              </form>
            </div>
        </div>
        <div id="comment-${commentId}-replies">${replies}</div>

        <div class="comment__additionalreply hide">
          <button class="comment__reply muted-link" aria-controls="comment${commentId}-reply" data-toggle="comment${commentId}-reply" aria-expanded="true">
            <svg role="none presentation" class="icon--pencil icon icon--small">
              <title></title>
              <use role="none presentation" href="/assets/decidim/icons-123.svg#icon-pencil"></use>
            </svg>
            &nbsp;Reply
          </button>
        </div>

        <div class="add-comment hide" id="comment${commentId}-reply" data-toggler=".hide">
          ${generateCommentForm("Comment", commentId)}
        </div>
      </div>
    `;
  };

  const generateCommentThread = (commentId, content, replies = "") => {
    return `
      <div>
        <div class="comment-thread">
          ${generateSingleComment(commentId, content, replies)}
        </div>
      </div>
    `
  }

  beforeEach(() => {
    let orderSelector = `
      <ul class="dropdown menu" data-dropdown-menu="data-dropdown-menu" data-autoclose="false" data-disable-hover="true" data-click-open="true" data-close-on-click="true" tabindex="-1" role="menubar">
        <li class="is-dropdown-submenu-parent opens-right" tabindex="-1" role="none">
          <a href="#" id="comments-order-menu-control" aria-label="Order by:" aria-controls="comments-order-menu" aria-haspopup="true" role="menuitem">Older</a>
          <ul class="menu is-dropdown-submenu submenu first-sub vertical" id="comments-order-chooser-menu" role="menu" aria-labelledby="comments-order-menu-control" tabindex="-1" data-submenu="">
            <li role="none" class="is-submenu-item is-dropdown-submenu-item">
              <a tabindex="-1" role="menuitem" data-remote="true" href="/comments?commentable_gid=commentable-gid&amp;order=best_rated&amp;reload=1">
                Best rated
              </a>
            </li>
            <li role="none" class="is-submenu-item is-dropdown-submenu-item">
              <a tabindex="-1" role="menuitem" data-remote="true" href="/comments?commentable_gid=commentable-gid&amp;order=recent&amp;reload=1">
                Recent
              </a>
            </li>
            <li role="none" class="is-submenu-item is-dropdown-submenu-item">
              <a tabindex="-1" role="menuitem" data-remote="true" href="/comments?commentable_gid=commentable-gid&amp;order=older&amp;reload=1">
                Older
              </a>
            </li>
            <li role="none" class="is-submenu-item is-dropdown-submenu-item">
              <a tabindex="-1" role="menuitem" data-remote="true" href="/comments?commentable_gid=commentable-gid&amp;order=most_discussed&amp;reload=1">
                Most discussed
              </a>
            </li>
          </ul>
        </li>
      </ul>
    `;

    let reply = generateSingleComment(451, "This is a reply.");
    let firstThread = generateCommentThread(450, "This is the first comment thread.", reply);
    let secondThread = generateCommentThread(452, "This is another comment thread.");

    let comments = `
      <div id="comments-for-Dummy-123" data-decidim-comments='{"singleComment":false,"toggleTranslations":false,"commentableGid":"commentable-gid","commentsUrl":"/comments","rootDepth":0,"lastCommentId":456,"order":"older"}'>
        <div class="columns large-9 comments-container" id="comments">
          <div class="comments">
            <div class="row collapse order-by">
              <h2 class="order-by__text section-heading">3 comments</h2>
              <div class="order-by__dropdown order-by__dropdown--right">
                <span class="order-by__text">Order by:</span>
                ${orderSelector}
              </div>
            </div>

            <div class="comment-threads">
              ${firstThread}
              ${secondThread}
            </div>
            <div class="add-comment">
              <h4 class="section-heading">Add your comment</h4>

              <div class="opinion-toggle button-group">
                <button class="button tiny button--muted opinion-toggle--ok">
                  <svg role="none presentation" class="icon--thumb-up icon">
                    <title></title>
                    <use role="none presentation" href="/assets/decidim/icons-2ba788b32e181c1a7197f7a54a0f03101c146dd434b9e56191690c7c2d7bdae3.svg#icon-thumb-up"></use>
                  </svg>
                </button>
                <button class="button tiny button--muted opinion-toggle--meh is-active">
                  Neutral
                </button>
                <button class="button tiny button--muted opinion-toggle--ko">
                  <svg role="none presentation" class="icon--thumb-down icon">
                    <title></title>
                    <use role="none presentation" href="/assets/decidim/icons-2ba788b32e181c1a7197f7a54a0f03101c146dd434b9e56191690c7c2d7bdae3.svg#icon-thumb-down"></use>
                  </svg>
                </button>
              </div>

              ${generateCommentForm("Dummy", 123)}
            </div>
          </div>
          <div class="callout primary loading-comments hide">
            <p>Loading comments ...</p>
          </div>
        </div>
      </div>
    `;
    $("body").append(comments);

    $container = $(document).find(selector);
    subject = new CommentsComponent($container, {
      commentableGid: "commentable-gid",
      commentsUrl: "/comments",
      rootDepth: 0,
      order: "older",
      lastCommentId: 456,
      pollingInterval: 1000
    });
    $("textarea[maxlength]", $container).each((_i, elem) => {
      createCharacterCounter($(elem));
    });

    $doc = $(document);
    addComment = $(".add-comment", subject.$element);
    orderLinks = $(".order-by__dropdown .is-submenu-item a", subject.$element);

    allToggles = $(".add-comment .opinion-toggle .button", subject.$element);
    allTextareas = $(".add-comment textarea", subject.$element);
    allForms = $(".add-comment form", subject.$element);
  });

  it("exists", () => {
    expect(CommentsComponent).toBeDefined();
  });

  it("initializes unmounted", () => {
    expect(subject.mounted).toBeFalsy();
  });

  it("initializes the comments element with the given selector", () => {
    expect(subject.$element).toEqual($(selector));
  });

  it("starts polling for new comments", () => {
    subject.mountComponent();

    expect(window.setTimeout).toHaveBeenLastCalledWith(expect.any(Function), 1000);

    jest.advanceTimersByTime(1000);

    expect(window.$.ajax).toHaveBeenCalledWith({
      url: "/comments",
      method: "GET",
      contentType: "application/javascript",
      data: {
        "commentable_gid": "commentable-gid",
        "root_depth": 0,
        order: "older",
        after: 456
      }
    });
  });

  describe("when mounted", () => {
    beforeEach(() => {
      spyOnAddComment("on");
      spyOn(orderLinks, "on");
      spyOn($doc, "trigger");

      subject.mountComponent();
    });

    afterEach(() => {
      subject.unmountComponent();
    });

    it("mounts the component", () => {
      expect(subject.mounted).toBeTruthy();
    });

    it("binds the order selector events", () => {
      expect(orderLinks.on).toHaveBeenCalledWith(
        "click.decidim-comments",
        expect.any(Function)
      );
    });

    it("binds the add comment element events", () => {
      addComment.each((i) => {
        expect(addComment[i].opinionToggles.on).toHaveBeenCalledWith(
          "click.decidim-comments",
          subject._onToggleOpinion
        );
        expect(addComment[i].commentTextarea.on).toHaveBeenCalledWith(
          "input.decidim-comments",
          subject._onTextInput
        );
        expect(addComment[i].commentForm.on).toHaveBeenCalledWith(
          "submit.decidim-comments",
          expect.any(Function)
        );
      });
    });

    it("attaches the mentions elements to the text fields", () => {
      addComment.each((i) => {
        expect($doc.trigger).toHaveBeenCalledWith(
          "attach-mentions-element",
          [addComment[i].commentTextarea[0]]
        );
      });
    });
  });

  describe("when interacting", () => {
    beforeEach(() => {
      spyOnAddComment();
      subject.mountComponent();
    });

    afterEach(() => {
      subject.unmountComponent();
    });

    describe("form and input events", () => {
      let commentSection = null;
      let commentForm = null;
      let commentText = null;

      beforeEach(() => {
        commentSection = addComment[addComment.length - 1];
        commentForm = commentSection.commentForm;
        commentText = commentSection.commentTextarea;

        // Avoid not implemented error
        commentForm[0].submit = jest.fn();
      });

      it("enables the submit button when comment is entered", () => {
        commentText.html("This is a test comment")
        commentText.trigger("input");

        expect(
          $("button[type='submit']", commentSection.commentForm).is(":enabled")
        ).toBeTruthy();
      });

      it("disables the submit button on submit and stops polling", () => {
        spyOn(window, "clearTimeout");

        commentText.html("This is a test comment")
        commentText.trigger("input");
        commentForm.trigger("submit");

        expect(
          $("button[type='submit']", commentSection.commentForm).is(":disabled")
        ).toBeTruthy();

        expect(window.clearTimeout).toHaveBeenCalledWith(subject.pollTimeout);
      });
    });

    describe("opinion toggles", () => {
      let commentSection = null;
      let toggles = null;

      beforeEach(() => {
        commentSection = addComment[addComment.length - 1];
        toggles = commentSection.opinionToggles;
      });

      it("adds the correct alignment on positive toggle", () => {
        $(toggles[0]).trigger("click");

        expect($(".alignment-input", commentSection).val()).toEqual("1");
      });

      it("adds the correct alignment on neutral toggle", () => {
        $(toggles[0]).trigger("click");
        $(toggles[1]).trigger("click");

        expect($(".alignment-input", commentSection).val()).toEqual("0");
      });

      it("adds the correct alignment on negative toggle", () => {
        $(toggles[2]).trigger("click");

        expect($(".alignment-input", commentSection).val()).toEqual("-1");
      });
    });
  });

  describe("when adding comments", () => {
    beforeEach(() => {
      subject.mountComponent();
    });

    afterEach(() => {
      subject.unmountComponent();
    });

    describe("addThread", () => {
      it("adds a new comment thread", () => {
        const newThread = generateCommentThread(999, "This is a dynamically added comment");
        subject.addThread(newThread);

        expect(subject.$element.html()).toEqual(expect.stringContaining(
          "This is a dynamically added comment"
        ));
      });
    });

    describe("addReply", () => {
      it("adds a new reply to an existing thread", () => {
        const newThread = generateSingleComment(999, "This is a dynamically added reply");
        subject.addReply(450, newThread);

        expect(subject.$element.html()).toEqual(expect.stringContaining(
          "This is a dynamically added reply"
        ));
      });
    });
  });

  describe("when unmounted", () => {
    beforeEach(() => {
      spyOn(orderLinks, "off");
      spyOn(allToggles, "off");
      spyOn(allTextareas, "off");
      spyOn(allForms, "off");

      subject.mountComponent();
      subject.unmountComponent();
    });

    it("mounts the component", () => {
      expect(subject.mounted).toBeFalsy();
    });

    it("unbinds the order selector events", () => {
      expect(orderLinks.off).toHaveBeenCalledWith(
        "click.decidim-comments"
      );
    });

    it("unbinds the add comment element events", () => {
      expect(allToggles.off).toHaveBeenCalledWith("click.decidim-comments");
      expect(allTextareas.off).toHaveBeenCalledWith("input.decidim-comments");
      expect(allForms.off).toHaveBeenCalledWith("submit.decidim-comments");
    });
  });

  afterEach(() => {
    $(selector).remove();
  })
});
