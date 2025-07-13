/* eslint-disable id-length, max-lines */
/* global jest */

const $ = require("jquery");

// Ability to spy on the jQuery methods inside the component in order to test
// the sub-elements correctly. Needs to be defined before the modules are loaded
// in order for them to define the $ variable correctly.
window.$ = jest.fn().mockImplementation((...args) => $(...args));
window.$.ajax = jest.fn().mockImplementation((...args) => $.ajax(...args));
window.$.extend = jest.fn().mockImplementation((...args) => $.extend(...args));

// Rails.ajax is used by the fetching/polling of the comments
import Rails from "@rails/ujs";
jest.mock("@rails/ujs");
window.Rails = Rails;

// Fake timers for testing polling
jest.useFakeTimers();

import { createCharacterCounter } from "src/decidim/input_character_counter";
import Configuration from "src/decidim/configuration";
// Component is loaded with require because using import loads it before $ has been mocked
// so tests are not able to check the spied behaviours
const CommentsComponent = require("./comments.component_for_testing.js");

// Create a dummy foundation jQuery method for the comments component to call
$.fn.foundation = () => {};

// Create the configuration object to make the configurations available for the tests
window.Decidim = {}
window.Decidim.config = new Configuration()

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
      addComment[i].opinionToggles = $("[data-opinion-toggle] button", addComment[i].$);
      addComment[i].commentForm = $("form", addComment[i].$);
      addComment[i].commentTextarea = $("textarea", addComment[i].commentForm);

      if (methodToSpy) {
        jest.spyOn(addComment[i].opinionToggles, methodToSpy);
        jest.spyOn(addComment[i].commentForm, methodToSpy);
        jest.spyOn(addComment[i].commentTextarea, methodToSpy);
      }
    });

    jest.spyOn(window, "$").mockImplementation((...args) => {
      const jqSelector = args[0];
      const parent = args[1];

      if (jqSelector === document) {
        return $doc;
      } else if (jqSelector === ".comment-order-by a.comment-order-by__item" && parent.is(subject.$element)) {
        return orderLinks;
      } else if (jqSelector === ".add-comment" && parent.is(subject.$element)) {
        return addComment;
      } else if (jqSelector === ".add-comment [data-opinion-toggle] button" && parent.is(subject.$element)) {
        return allToggles;
      } else if (jqSelector === ".add-comment textarea" && parent.is(subject.$element)) {
        return allTextareas;
      } else if (jqSelector === ".add-comment form" && parent.is(subject.$element)) {
        return allForms;
      }
      const addCommentsArray = addComment.toArray();
      for (let i = 0; i < addCommentsArray.length; i += 1) {
        if (jqSelector === "[data-opinion-toggle] button" && parent.is(addCommentsArray[i].$)) {
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
      <input class="alignment-input" autocomplete="off" type="hidden" value="0" name="comment[alignment]">
      <div class="comment__as">
      <label for="add-comment-${modelName}-${modelId}-user-group-id">
        Comment as
      </label>
      <select id="add-comment-${modelName}-${modelId}-user-group-id" name="comment[user_group_id]">
        <option value="">Renetta Okuneva</option>
        <option value="6">Pollich-Ratke</option>
      </select>
    </div>

      <div class="form__wrapper gap-2">
        <label for="add-comment-${modelName}-${modelId}">
          Comment
        </label>
        <span class="emoji__container">
          <textarea
            required="required"
            maxlength="1000"
            id="add-comment-${modelName}-${modelId}"
            class="w-full rounded border min-h-[160px] border-text-gray-2"
            placeholder="What do you think about this?"
            data-remaining-characters="#add-comment-${modelName}-${modelId}-remaining-characters"
            data-input-emoji="true"
            name="comment[body]"
            aria-describedby="add-comment-${modelName}-${modelId}-remaining-characters_sr"
            data-input-emoji-initialized="true"
            data-tribute="true">
          </textarea>
          <span class="emoji__trigger">
            <button class="emoji__button" type="button" aria-label="Add emoji">
              <svg aria-hidden="true" focusable="false" data-prefix="far" data-icon="smile" role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 496 512">
                <path fill="currentColor" d="M248 8C111 8 0 119 0 256s111 248 248 248 248-111 248-248S385 8 248 8zm0 448c-110.3 0-200-89.7-200-200S137.7 56 248 56s200 89.7 200 200-89.7 200-200 200zm-80-216c17.7 0 32-14.3 32-32s-14.3-32-32-32-32 14.3-32 32 14.3 32 32 32zm160 0c17.7 0 32-14.3 32-32s-14.3-32-32-32-32 14.3-32 32 14.3 32 32 32zm4 72.6c-20.8 25-51.5 39.4-84 39.4s-63.2-14.3-84-39.4c-8.5-10.2-23.7-11.5-33.8-3.1-10.2 8.5-11.5 23.6-3.1 33.8 30 36 74.1 56.6 120.9 56.6s90.9-20.6 120.9-56.6c8.5-10.2 7.1-25.3-3.1-33.8-10.1-8.4-25.3-7.1-33.8 3.1z">
                </path>
              </svg>
           </button>
          </span>
          <span class="emoji__reference" style="position: absolute; display: block; bottom: -8px; right: -16px;"></span>
          <span class="form-error">There is an error in this field.</span>
        </span>
        <span role="status" id="add-comment-${modelName}-${modelId}-remaining-characters_sr" class="sr-only remaining-character-count-sr">1000 characters left</span>
        <span id="add-comment-${modelName}-${modelId}-remaining-characters" class="remaining-character-count show-erb-comment" aria-hidden="true">1000 characters left</span>
        <div class="w-full text-right">
          <button type="submit" class="button button__sm button__secondary" disabled="disabled">
            <span>Publish comment</span>
            <svg width="1em" height="1em" role="img" aria-hidden="true"><use href="/decidim-packs/media/images/remixicon.symbol-5540ed538fb6bd400d2a.svg#ri-chat-1-line" tabindex="-1"></use></svg>
          </button>
        </div>
      </div>
    </form>
    `;
  };

  const generateFlagModalForm = (commentId) => {
    return `
      <div id="flagModalComment${commentId}" data-dialog="flagModalComment${commentId}" role="dialog" tabindex="-1" aria-hidden="true" aria-labelledby="dialog-title-flagModalComment${commentId}" aria-modal="true"><div id="flagModalComment${commentId}-content"><button type="button" data-dialog-close="flagModalComment${commentId}" data-dialog-closable="" aria-label="Close modal">×</button>
        <form class="modal__report form-defaults" novalidate="novalidate" data-abide="true" data-live-validate="true" data-validate-on-blur="true" action="/report?sgid=BAh7CEkiCGdpZAY6BkVUSSJBZ2lkOi8vZGVjaWRpbS1kZXZlbG9wbWVudC1hcHAvRGVjaWRpbTo6Q29tbWVudHM6OkNvbW1lbnQvODMyBjsAVEkiDHB1cnBvc2UGOwBUSSIMZGVmYXVsdAY7AFRJIg9leHBpcmVzX2F0BjsAVEkiHTIwMjMtMDEtMTlUMDM6MzA6MzMuNDM2WgY7AFQ%3D--7b3754f17d4b3f13b7065d98eba5b44a0d9af373" accept-charset="UTF-8" method="post"><input type="hidden" name="authenticity_token" value="4gZ0SkWxuyZ0SyUWhphWwAju8XO4c44aOJr1zGRfbGC19ZssM1mhifceP4zjs8e6UQbOWGO921OMR_XxS4PBxw" autocomplete="off">
          <div data-dialog-container="">
            <svg width="1em" height="1em" role="img" aria-hidden="true" class="inline-block align-middle"><use href="/decidim-packs/media/images/remixicon.symbol-5540ed538fb6bd400d2a.svg#ri-flag-line" tabindex="-1"></use></svg>
            <h3 data-dialog-title="" id="dialog-title-flagModalComment${commentId}">
              Report inappropriate content
            </h3>
            <div>
              <p class="modal__report-text">
                Is this content inappropriate?
              </p>
              <fieldset>
                <legend>Reason</legend>
                <input type="hidden" name="report[reason]" value="" autocomplete="off">
                  <div class="modal__report-container__radio">
                    <input id="spam" type="radio" value="spam" checked="checked" name="report[reason]">
                    <label for="spam">
                      Contains clickbait, advertising, scams or script bots.
                    </label>
                  </div>

                  <div class="modal__report-container__radio">
                    <input id="offensive" type="radio" value="offensive" name="report[reason]">
                    <label for="offensive">
                      Contains racism, sexism, slurs, personal attacks, death threats, suicide requests or any form of hate speech.
                    </label>
                  </div>

                  <div class="modal__report-container__radio">
                    <input id="does_not_belong" type="radio" value="does_not_belong" name="report[reason]">
                    <label for="does_not_belong">
                      Contains illegal activity, suicide threats, personal information, or something else you think does not belong on Reichel, Bernhard and Glover.
                    </label>
                  </div>
              </fieldset>
              <label for="flagModalComment${commentId}" class="text-gray-2">Additional comments<textarea class="w-full rounded border min-h-[160px] border-text-gray-2 mt-2" id="flagModalComment${commentId}" name="report[details]"></textarea></label>
            </div>
          </div>
          <div data-dialog-actions="">
            <button type="submit" class="button button__lg button__secondary">
              <span>
                Report
              </span>
              <svg width="1em" height="1em" role="img" aria-hidden="true"><use href="/decidim-packs/media/images/remixicon.symbol-5540ed538fb6bd400d2a.svg#ri-arrow-right-line" tabindex="-1"></use></svg>
            </button>
          </div>
        </form>
      </div>
    `;
  }

  const generateSingleComment = (commentId, content, replies = "") => {
    return `
      <div id="comment_${commentId}" class="comment" data-comment-id="${commentId}">
        <div class="comment__header">
          <span class="font-bold">
            <a class="flex items-center gap-2.5" href="/profiles/kathline">
              <span class="rounded-full overflow-hidden inline-block w-6 h-6">
                <img alt="Avatar: Buster Hammes" class="w-full h-full object-cover" src="/decidim-packs/media/images/default-avatar-aaa9e55bac5d7159b847.svg">
              </span>
              <span>Buster Hammes</span>
            </a>
          </span>
          <span class="text-gray-2 text-sm"><time datetime="2022-12-15T11:19:22Z">4 days ago</time></span>
          <details class="ml-auto">
            <summary class="button button__sm button__text-secondary" aria-controls="toggle-context-menu-${commentId}">
              <svg width="1em" height="1em" role="img" aria-hidden="true"><use href="/decidim-packs/media/images/remixicon.symbol-5540ed538fb6bd400d2a.svg#ri-more-line" tabindex="-1"></use></svg>
            </summary>
            <ul id="toggle-context-menu-${commentId}" class="dropdown dropdown__bottom divide-y divide-gray-3">
              <li>
                <button type="button" class="dropdown__item" data-dialog-open="flagModalComment${commentId}" title="Report" aria-controls="flagModalComment${commentId}" aria-haspopup="dialog" tabindex="0">
                  <svg width="1em" height="1em" role="img" aria-hidden="true"><use href="/decidim-packs/media/images/remixicon.symbol-5540ed538fb6bd400d2a.svg#ri-flag-line" tabindex="-1"></use></svg>
                  <span>Report</span>
                </button>
              </li>
              <li>
                <a target="_blank" data-external-link="false" class="dropdown__item" title="Get link" tabindex="1" href="/processes/enim-consectetur/f/9/posts/2?commentId=${commentId}#comment_${commentId}">
                  <svg width="1em" height="1em" role="img" aria-hidden="true"><use href="/decidim-packs/media/images/remixicon.symbol-5540ed538fb6bd400d2a.svg#ri-share-line" tabindex="-1"></use></svg>
                  <span>Get link</span>
                <span class="inline-block mx-0.5"><svg class="icon icon--external-link w-2 h-2 fill-current" role="img" aria-hidden="true"><title>external-link</title><use href="/decidim-packs/media/images/remixicon.symbol-5540ed538fb6bd400d2a.svg#icon-external-link"></use></svg><span class="sr-only">(External link)</span></span></a>
              </li>
            </ul>
          </details>
          ${generateFlagModalForm(commentId)}
        </div>
        <div class="comment__content">
          <div><p>${content}</p></div>
        </div>
        <div data-comment-footer data-component="accordion" role="presentation">
          <div class="comment__footer-grid">
            <div class="comment__actions">
              <button class="button button__sm button__text-secondary" data-controls="panel-comment${commentId}-reply" role="button" tabindex="0" aria-controls="panel-comment${commentId}-reply" aria-expanded="false" aria-disabled="false">
                <svg width="1em" height="1em" role="img" aria-hidden="true"><use href="/decidim-packs/media/images/remixicon.symbol-5540ed538fb6bd400d2a.svg#ri-chat-1-line" tabindex="-1"></use></svg>
                <span class="font-normal">Reply</span>
                <svg width="1em" height="1em" role="img" aria-hidden="true"><use href="/decidim-packs/media/images/remixicon.symbol-5540ed538fb6bd400d2a.svg#ri-close-circle-line" tabindex="-1"></use></svg>
                <span class="font-normal">Cancel reply</span>
              </button>
            </div>
            <div class="comment__votes">
              <form class="button_to" method="post" action="/comments/${commentId}/votes?weight=1" data-remote="true">
                <button class="button button__sm button__text-secondary js-comment__votes--up" title="I agree with this comment" type="submit">
                  <svg width="1em" height="1em" role="img" aria-hidden="true"><use href="/decidim-packs/media/images/remixicon.symbol-5540ed538fb6bd400d2a.svg#ri-thumb-up-line" tabindex="-1"></use></svg>
                  <svg width="1em" height="1em" role="img" aria-hidden="true"><use href="/decidim-packs/media/images/remixicon.symbol-5540ed538fb6bd400d2a.svg#ri-thumb-up-fill" tabindex="-1"></use></svg>
                  <span>0</span>
                </button>
                <input type="hidden" name="authenticity_token" value="knr7y99HXbKv5sdm5OlghBlFsjIX7KOnIvHZ5-vXThb87Qszlh8j_CPxdbhsiqcIPAwvofsM9zR0vWFgojq6dA" autocomplete="off">
              </form>
              <form class="button_to" method="post" action="/comments/${commentId}/votes?weight=-1" data-remote="true">
                <button class="button button__sm button__text-secondary js-comment__votes--down" title="I disagree with this comment" type="submit">
                  <svg width="1em" height="1em" role="img" aria-hidden="true"><use href="/decidim-packs/media/images/remixicon.symbol-5540ed538fb6bd400d2a.svg#ri-thumb-down-line" tabindex="-1"></use></svg>
                  <svg width="1em" height="1em" role="img" aria-hidden="true"><use href="/decidim-packs/media/images/remixicon.symbol-5540ed538fb6bd400d2a.svg#ri-thumb-down-fill" tabindex="-1"></use></svg>
                  <span>0</span>
                </button>
                <input type="hidden" name="authenticity_token" value="OOIZTq0QSU1CB6OXV1D6j337zCgOA6al6xDOmy_qlZpWdem25Eg3A84QEUnfMz0DWLJRu-Lj8ja9XHYcZgdh-A" autocomplete="off">
              </form>
            </div>
          </div>
          <div id="panel-comment${commentId}-reply" class="add-comment" role="region" tabindex="-1" aria-labelledby="" aria-hidden="true">
            ${generateCommentForm("Comment", commentId)}
          </div>
        </div>
        <div id="comment-${commentId}-replies">${replies}</div>
      </div>
    `;
  }

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
      <div class="comment-order-by">
        <div class="text-center">
          <a class="button button__sm button__text-secondary only:m-auto comment-order-by__item inline-block " data-remote="true" href="/comments?commentable_gid=commentable-gid&amp;order=best_rated&amp;reload=1">Best rated</a>
        </div>

        <div class="text-center">
          <a class="button button__sm button__text-secondary only:m-auto comment-order-by__item inline-block " data-remote="true" href="/comments?commentable_gid=commentable-gid&amp;order=recent&amp;reload=1">Recent</a>
        </div>

        <div class="text-center">
          <a class="button button__sm button__text-secondary only:m-auto comment-order-by__item inline-block underline font-bold" data-remote="true" href="/comments?commentable_gid=commentable-gid&amp;order=older&amp;reload=1">Older</a>
        </div>

        <div class="text-center">
          <a class="button button__sm button__text-secondary only:m-auto comment-order-by__item inline-block " data-remote="true" href="/comments?commentable_gid=commentable-gid&amp;order=most_discussed&amp;reload=1">Most discussed</a>
        </div>
      </div>
    `;

    let reply = generateSingleComment(451, "This is a reply.");
    let firstThread = generateCommentThread(450, "This is the first comment thread.", reply);
    let secondThread = generateCommentThread(452, "This is another comment thread.");

    let comments = `
      <div id="comments-for-Dummy-123" data-decidim-comments='{"singleComment":false,"toggleTranslations":false,"commentableGid":"commentable-gid","commentsUrl":"/comments","rootDepth":0,"lastCommentId":456,"order":"older"}'>
        <div id="comments">
          <div class="comments">
            <div class="comments__header">
              <h2 class="h4">
              <svg width="1em" height="1em" role="img" aria-hidden="true" class="fill-tertiary w-6 h-6 inline-block align-middle"><use href="/decidim-packs/media/images/remixicon.symbol-5540ed538fb6bd400d2a.svg#ri-chat-1-line" tabindex="-1"></use></svg>
                <span class="comments-count inline-block align-middle">3 comments</span>
              </h2>
              ${orderSelector}
            </div>

            <div class="comment-threads">
              ${firstThread}
              ${secondThread}
            </div>
            <div class="add-comment">
              <div data-opinion-toggle class="button-group comment__opinion-container">
                <span class="py-1.5">Your opinion about this topic</span>
                <button aria-pressed="false" class="button button__sm button__text-secondary" data-toggle-ok="true" data-selected-label="Your opinion about this topic is positive">
                  <svg width="1em" height="1em" role="img" aria-hidden="true"><use href="/decidim-packs/media/images/remixicon.symbol-5540ed538fb6bd400d2a.svg#ri-thumb-up-line" tabindex="-1"></use></svg>
                  <svg width="1em" height="1em" role="img" aria-hidden="true"><use href="/decidim-packs/media/images/remixicon.symbol-5540ed538fb6bd400d2a.svg#ri-thumb-up-fill" tabindex="-1"></use></svg>
                  <span>Positive</span>
                </button>
                <button aria-pressed="true" class="button button__sm button__text-secondary is-active" data-toggle-meh="true" data-selected-label="Your opinion about this topic is neutral">
                  <span>Neutral
                  </span>
                </button>
                <button aria-pressed="false" class="button button__sm button__text-secondary"  data-toggle-ko="true" data-selected-label="Your opinion about this topic is negative">
                  <svg width="1em" height="1em" role="img" aria-hidden="true"><use href="/decidim-packs/media/images/remixicon.symbol-5540ed538fb6bd400d2a.svg#ri-thumb-down-line" tabindex="-1"></use></svg>
                  <svg width="1em" height="1em" role="img" aria-hidden="true"><use href="/decidim-packs/media/images/remixicon.symbol-5540ed538fb6bd400d2a.svg#ri-thumb-down-fill" tabindex="-1"></use></svg>
                  <span>Negative</span>
                </button>
                <div role="alert" aria-live="assertive" aria-atomic="true" class="selected-state sr-only"></div>
              </div>
              ${generateCommentForm("Dummy", 123)}
            </div>
            <div class="flash primary loading-comments hidden">
              <div class="flash__message">
                Loading comments ...
              </div>
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
    orderLinks = $(".comment-order-by a.comment-order-by__item", subject.$element);

    allToggles = $(".add-comment [data-opinion-toggle] .button", subject.$element);
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
    expect(subject.$element[0]).toEqual($(selector)[0]);
  });

  it("loads the comments through AJAX", () => {
    subject.mountComponent();

    expect(Rails.ajax).toHaveBeenCalledWith({
      url: "/comments",
      type: "GET",
      data: new URLSearchParams({
        "commentable_gid": "commentable-gid",
        "root_depth": 0,
        order: "older",
        after: 456
      }),
      success: expect.any(Function)
    });
  });

  it("disables the comment textarea", () => {
    subject.mountComponent();

    expect($(`${selector} .add-comment textarea`).prop("disabled")).toBeTruthy();
  });

  it("re-enables the comment textarea after a successful fetch", () => {
    Rails.ajax.mockImplementationOnce((options) => options.success());

    subject.mountComponent();

    expect($(`${selector} .add-comment textarea`).prop("disabled")).toBeFalsy();
  });

  it("starts polling for new comments", () => {
    jest.spyOn(window, "setTimeout");
    Rails.ajax.mockImplementationOnce((options) => options.success());

    subject.mountComponent();

    expect(window.setTimeout).toHaveBeenLastCalledWith(expect.any(Function), 1000);
  });

  it("does not disable the textarea when polling comments normally", () => {
    Rails.ajax.mockImplementationOnce((options) => options.success());

    subject.mountComponent();

    // Delay the success call 2s after the polling has happened to test that
    // the textarea is still enabled when the polling is happening.
    Rails.ajax.mockImplementationOnce((options) => {
      setTimeout(() => options.success(), 2000);
    });
    jest.advanceTimersByTime(1500);

    expect($(`${selector} .add-comment textarea`).prop("disabled")).toBeFalsy();
  });

  describe("when mounted", () => {
    beforeEach(() => {
      spyOnAddComment("on");
      jest.spyOn(orderLinks, "on");
      jest.spyOn($doc, "trigger");

      subject.mountComponent();
    });

    afterEach(() => {
      subject.unmountComponent();
    });

    it("mounts the component", () => {
      expect(subject.mounted).toBeTruthy();
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
      Rails.ajax.mockImplementationOnce((options) => options.success());
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
        jest.spyOn(window, "clearTimeout");

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
      let toggleContainer = null;

      beforeEach(() => {
        commentSection = addComment[addComment.length - 1];
        toggles = commentSection.opinionToggles;
        toggleContainer = $(toggles[0]).parent();
      });

      it("adds the correct alignment on positive toggle", () => {
        $(toggles[0]).trigger("click");

        expect($(toggles[0]).attr("aria-pressed")).toEqual("true");
        expect($(toggles[1]).attr("aria-pressed")).toEqual("false");
        expect($(toggles[2]).attr("aria-pressed")).toEqual("false");
        expect($(".alignment-input", commentSection).val()).toEqual("1");
        expect($(".selected-state", toggleContainer).text()).toEqual("Your opinion about this topic is positive");
      });

      it("adds the correct alignment on neutral toggle", () => {
        $(toggles[0]).trigger("click");
        $(toggles[1]).trigger("click");

        expect($(toggles[0]).attr("aria-pressed")).toEqual("false");
        expect($(toggles[1]).attr("aria-pressed")).toEqual("true");
        expect($(toggles[2]).attr("aria-pressed")).toEqual("false");
        expect($(".alignment-input", commentSection).val()).toEqual("0");
        expect($(".selected-state", toggleContainer).text()).toEqual("Your opinion about this topic is neutral");
      });

      it("adds the correct alignment on negative toggle", () => {
        $(toggles[2]).trigger("click");

        expect($(toggles[0]).attr("aria-pressed")).toEqual("false");
        expect($(toggles[1]).attr("aria-pressed")).toEqual("false");
        expect($(toggles[2]).attr("aria-pressed")).toEqual("true");
        expect($(".alignment-input", commentSection).val()).toEqual("-1");
        expect($(".selected-state", toggleContainer).text()).toEqual("Your opinion about this topic is negative");
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

      it("does not clear the comment form text area", () => {
        const commentSection = addComment[addComment.length - 1];
        const textArea = $("textarea", commentSection);
        textArea.val("I am writing a new comment...");

        const newThread = generateCommentThread(999, "This is a dynamically added comment");
        subject.addThread(newThread);

        expect(textArea.val()).toEqual("I am writing a new comment...");
      });

      describe("as the current user", () => {
        it("clears the comment form text area", () => {
          const commentSection = addComment[addComment.length - 1];
          const textArea = $("textarea", commentSection);
          textArea.val("I am writing a new comment...");

          const newThread = generateCommentThread(999, "This is a dynamically added comment");
          const alignment = null;
          subject.addThread(newThread, alignment, true);

          expect(textArea.val()).toEqual("");
        });
      });
    });

    describe("addReply", () => {
      const newReply = generateSingleComment(999, "This is a dynamically added reply");

      it("adds a new reply to an existing thread", () => {
        subject.addReply(450, newReply);

        expect(subject.$element.html()).toEqual(expect.stringContaining(
          "This is a dynamically added reply"
        ));
      });

      it("does not clear the reply comment form text area", () => {
        const commentSection = $("#comment-450-replies", subject.$element);
        const textArea = $("textarea", commentSection);
        textArea.val("I am writing a new comment...");

        subject.addReply(450, newReply);

        expect(textArea.val()).toEqual("I am writing a new comment...");
      });

      describe("as the current user", () => {
        it("clears the comment form text area", () => {
          const commentSection = $(".add-comment", subject.$element);
          const textArea = $("textarea", commentSection);
          textArea.val("I am writing a new comment...");

          subject.addReply(450, newReply, true);

          expect(textArea.val()).toEqual("");
        });
      });
    });
  });

  describe("when unmounted", () => {
    beforeEach(() => {
      jest.spyOn(orderLinks, "off");
      jest.spyOn(allToggles, "off");
      jest.spyOn(allTextareas, "off");
      jest.spyOn(allForms, "off");

      subject.mountComponent();
      subject.unmountComponent();
    });

    it("mounts the component", () => {
      expect(subject.mounted).toBeFalsy();
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
