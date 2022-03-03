/* global jest, global */

// Mock jQuery because the visibility indicator works differently within jest.
// This fixes jQuery reporting $(".element").is(":visible") correctly during the
// tests and within foundation, too.
jest.mock("jquery", () => {
  const jq = jest.requireActual("jquery");

  jq.expr.pseudos.visible = (elem) => {
    const display = global.window.getComputedStyle(elem).display;
    return ["inline", "block", "inline-block"].includes(display);
  };

  return jq;
});

import $ from "jquery"; // eslint-disable-line id-length
import "foundation-sites";

import FocusGuard from "./focus_guard.js";
import dialogMode from "./dialog_mode.js";

describe("dialogMode", () => {
  const content = `
    <div class="reveal" id="test-modal" data-reveal aria-modal="true" aria-labelledby="test-modal-label">
      <div class="reveal__header">
        <h3 id="test-modal-label" class="reveal__title">Testing modal</h3>
        <button class="close-button" data-close aria-label="Close window"
          type="button">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="row">
        <div class="columns medium-4 medium-centered">
          <p>Here is some content within the modal.</p>
          <button type="button" id="test-modal-button">Button at the bottom</button>
        </div>
      </div>
    </div>

    <div class="reveal" id="test-modal-2" data-reveal aria-modal="true" aria-labelledby="test-modal-2-label">
      <div class="reveal__header">
        <h3 id="test-modal-2-label" class="reveal__title">Other testing modal</h3>
        <button class="close-button" data-close aria-label="Close window"
          type="button">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="row">
        <div class="columns medium-4 medium-centered">
          <p>Here is some content within the other modal.</p>
          <button type="button" id="test-modal-2-button">Button at the bottom</button>
        </div>
      </div>
    </div>
  `;

  window.focusGuard = new FocusGuard(document.body);

  // Mock the isVisible element because these elements do not have offsetWidth
  // or offsetHeight during the test which are checked against to see whether
  // the element is visible or not.
  jest.spyOn(window.focusGuard, "isVisible").mockImplementation((element) => {
    const display = global.window.getComputedStyle(element).display;
    return ["inline", "block", "inline-block"].includes(display);
  });

  beforeEach(() => {
    $("body").html(content);

    $(document).foundation();

    // Make sure all reveals are hidden by default so that their visibility is
    // correctly reported always.
    $(".reveal").css("display", "none");

    $(document).on("open.zf.reveal", (ev) => {
      dialogMode($(ev.target));
    });
  });

  it("focuses the title", () => {
    $("#test-modal").foundation("open");

    const $focused = $(document.activeElement);
    expect($focused.is($("#test-modal-label"))).toBe(true);
  });

  it("adds the tab guads on both sides of the document", () => {
    $("#test-modal").foundation("open");

    const $first = $("body *:first");
    const $last = $("body *:last");

    expect($first[0].outerHTML).toEqual(
      '<div class="focusguard" data-position="start" tabindex="0" aria-hidden="true"></div>'
    );
    expect($last[0].outerHTML).toEqual(
      '<div class="focusguard" data-position="end" tabindex="0" aria-hidden="true"></div>'
    );
  });

  it("removes the tab guards when the modal is closed", () => {
    const $modal = $("#test-modal");
    $modal.foundation("open");
    $modal.foundation("close");

    expect($(".focusguard").length).toEqual(0);
  });

  it("focuses the first focusable element when the start tab guard gets focus", () => {
    const $modal = $("#test-modal");
    $modal.foundation("open");

    $(".focusguard[data-position='start']").trigger("focus");

    const $focused = $(document.activeElement);
    expect($focused.is($("#test-modal .close-button"))).toBe(true);
  });

  it("focuses the last focusable element when the end tab guard gets focus", () => {
    const $modal = $("#test-modal");
    $modal.foundation("open");

    $(".focusguard[data-position='end']").trigger("focus");

    const $focused = $(document.activeElement);
    expect($focused.is($("#test-modal-button"))).toBe(true);
  });

  describe("when multiple modals are opened", () => {
    it("adds the tab guads only once", () => {
      $("#test-modal").foundation("open");
      $("#test-modal-2").foundation("open");

      expect($(".focusguard[data-position='start']").length).toEqual(1);
      expect($(".focusguard[data-position='end']").length).toEqual(1);
    });

    it("does not remove the tab guards when modal is closed but there is still another modal open", () => {
      $("#test-modal").foundation("open");
      $("#test-modal-2").foundation("open");
      $("#test-modal-2").foundation("close");

      expect($(".focusguard[data-position='start']").length).toEqual(1);
      expect($(".focusguard[data-position='end']").length).toEqual(1);
    });

    it("removes the tab guards when the last modal is closed", () => {
      $("#test-modal").foundation("open");
      $("#test-modal-2").foundation("open");
      $("#test-modal-2").foundation("close");
      $("#test-modal").foundation("close");

      expect($(".focusguard").length).toEqual(0);
    });

    describe("within the active modal", () => {
      beforeEach(() => {
        $("#test-modal").foundation("open");
        $("#test-modal-2").foundation("open");
      });

      it("focuses the first focusable element when the start tab guard gets focus", () => {
        $(".focusguard[data-position='start']").trigger("focus");

        const $focused = $(document.activeElement);
        expect($focused.is($("#test-modal-2 .close-button"))).toBe(true);
      });

      it("focuses the last focusable element when the end tab guard gets focus", () => {
        $(".focusguard[data-position='end']").trigger("focus");

        const $focused = $(document.activeElement);
        expect($focused.is($("#test-modal-2-button"))).toBe(true);
      });
    });
  });
});
