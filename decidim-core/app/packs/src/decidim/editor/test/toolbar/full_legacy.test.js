/* global jest, global */

// import Dialog from "a11y-dialog-component";
import $ from "jquery"; // eslint-disable-line id-length
import "foundation-sites";

import { createEditorContainer, sleep, updateContent, selectContent, dropFixtureFile } from "../helpers";
import contextHelpers from "./shared/context";
import itBehavesLikeContentToolbar from "./shared/behaves_like_content";

// global.$ = $; // eslint-disable-line id-length

describe("full toolbar", () => {
  const ctx = {
    editorContainer: null
  };

  beforeEach(() => {
    document.body.innerHTML = "";
    ctx.editorContainer = createEditorContainer({ design: "legacy" })

    // Initialize foundation
    $(document).foundation();
    $(".reveal").css("display", "none");
  });

  const { getControl } = contextHelpers(ctx);

  itBehavesLikeContentToolbar(ctx);

  describe("multimedia toolbar controls", () => {
    let prosemirror = null;

    const setContent = async (editorContent) => {
      await updateContent(prosemirror, editorContent);
    }

    beforeEach(() => {
      prosemirror = ctx.editorContainer.querySelector(".editor-input .ProseMirror");
    });

    describe("videoEmbed", () => {
      it("creates a new video embed with the provided details at the end of the selection", async () => {
        await setContent("Hello, world!");
        prosemirror.focus();

        // Open the video embed dialog and set the values
        getControl("videoEmbed").click();

        const dialog = document.body.lastElementChild;
        dialog.querySelector("[data-input='src'] input").value = "https://www.youtube.com/watch?v=f6JMgJAQ2tc";
        dialog.querySelector("[data-input='title'] input").value = "Decidim";
        dialog.querySelector("button[data-action='save']").click();
        $(dialog.querySelector("[data-reveal]")).trigger("closed.zf.reveal");

        // Wait for the next event loop as this is when the dialog closing is
        // handled
        await sleep(0);

        expect(prosemirror.innerHTML).toMatchHtml(
          `
            <p>Hello, world!</p>
            <div class="editor-content-videoEmbed ProseMirror-selectednode" data-video-embed="https://www.youtube.com/watch?v=f6JMgJAQ2tc" draggable="true">
              <div>
                <iframe src="https://www.youtube-nocookie.com/embed/f6JMgJAQ2tc?cc_load_policy=1&amp;modestbranding=1" title="Decidim" frameborder="0" allowfullscreen="true"></iframe>
              </div>
            </div>
          `
        );
      });

      it("allows modifying an existing video embed", async () => {
        await setContent(`
          <p>Hello, world!</p>
          <div class="editor-content-videoEmbed" data-video-embed="https://www.youtube.com/watch?v=f6JMgJAQ2tc" draggable="true">
            <div>
              <iframe src="https://www.youtube-nocookie.com/embed/f6JMgJAQ2tc?cc_load_policy=1&amp;modestbranding=1" title="Decidim" frameborder="0" allowfullscreen="true"></iframe>
            </div>
          </div>
        `);

        selectContent(prosemirror, "div.editor-content-videoEmbed");

        // Open the video embed dialog and set the values
        getControl("videoEmbed").click();

        const dialog = document.body.lastElementChild;

        const srcInput = dialog.querySelector("[data-input='src'] input");
        const titleInput = dialog.querySelector("[data-input='title'] input");

        expect(srcInput.value).toEqual("https://www.youtube.com/watch?v=f6JMgJAQ2tc");
        expect(titleInput.value).toEqual("Decidim");

        srcInput.value = "https://www.youtube.com/watch?v=zhMMW0TENNA";
        titleInput.value = "Free Open-Source participatory democracy";
        dialog.querySelector("button[data-action='save']").click();
        $(dialog.querySelector("[data-reveal]")).trigger("closed.zf.reveal");

        // Wait for the next event loop as this is when the dialog closing is
        // handled
        await sleep(0);

        expect(prosemirror.innerHTML).toMatchHtml(
          `
            <p>Hello, world!</p>
            <div class="editor-content-videoEmbed ProseMirror-selectednode" data-video-embed="https://www.youtube.com/watch?v=zhMMW0TENNA" draggable="true">
              <div>
                <iframe src="https://www.youtube-nocookie.com/embed/zhMMW0TENNA?cc_load_policy=1&amp;modestbranding=1" title="Free Open-Source participatory democracy" frameborder="0" allowfullscreen="true"></iframe>
              </div>
            </div>
          `
        );
      });
    });

    describe("image", () => {
      let uploadDialog = null;

      global.fetch = jest.fn(() =>
        Promise.resolve({ ok: true, json: () => Promise.resolve({ url: "/path/to/logo.png" }) })
      );

      beforeEach(() => {
        const csrf = document.createElement("meta");
        csrf.setAttribute("name", "csrf-token")
        csrf.setAttribute("content", "abcdef0123456789")
        document.head.append(csrf);

        uploadDialog = document.getElementById("upload_dialog");
      });

      it("creates a new image with the provided details at the end of the selection", async () => {
        await setContent("Hello, world!");
        prosemirror.focus();

        // Open the video embed dialog and set the values
        getControl("image").click();

        // Simulate the file drop, set the alt title and click save
        const dropZone = uploadDialog.querySelector(".dropzone-container .dropzone");
        await dropFixtureFile(dropZone, "logo.png");

        uploadDialog.querySelector("input.attachment-title").value = "Decidim logo";
        uploadDialog.querySelector("button.add-file-file").click();
        $(uploadDialog).trigger("closed.zf.reveal");

        await sleep(0);

        expect(prosemirror.innerHTML).toMatchHtml(
          `
            <p>Hello, world!</p>
            <div data-image-resizer="" class="ProseMirror-selectednode" draggable="true">
              <div data-image-resizer-wrapper="">
                <button type="button" data-image-resizer-control="top-left"></button>
                <button type="button" data-image-resizer-control="top-right"></button>
                <button type="button" data-image-resizer-control="bottom-left"></button>
                <button type="button" data-image-resizer-control="bottom-right"></button>
                <div data-image-resizer-dimensions="">
                  <span data-image-resizer-dimension="width" data-image-resizer-dimension-value=""></span>
                  ×
                  <span data-image-resizer-dimension="height" data-image-resizer-dimension-value=""></span>
                </div>
                <div class="editor-content-image" data-image="">
                  <img src="/path/to/logo.png" alt="Decidim logo">
                </div>
              </div>
            </div>
          `
        );
      });

      it("allows modifying an existing image", async () => {
        await setContent(`
          <p>Hello, world!</p>
          <div class="editor-content-image" data-image="">
            <img src="/existing/image.jpg" alt="Testing">
          </div>
        `);

        selectContent(prosemirror, "[data-image-resizer] img");

        // Open the video embed dialog and set the values
        getControl("image").click();

        const dropZone = uploadDialog.querySelector(".dropzone-container .dropzone");
        await dropFixtureFile(dropZone, "logo.png");

        uploadDialog.querySelector("input.attachment-title").value = "Decidim logo";
        uploadDialog.querySelector("button.add-file-file").click();
        $(uploadDialog).trigger("closed.zf.reveal");

        await sleep(0);

        expect(prosemirror.innerHTML).toMatchHtml(
          `
            <p>Hello, world!</p>
            <div data-image-resizer="" class="ProseMirror-selectednode" draggable="true">
              <div data-image-resizer-wrapper="">
                <button type="button" data-image-resizer-control="top-left"></button>
                <button type="button" data-image-resizer-control="top-right"></button>
                <button type="button" data-image-resizer-control="bottom-left"></button>
                <button type="button" data-image-resizer-control="bottom-right"></button>
                <div data-image-resizer-dimensions="">
                  <span data-image-resizer-dimension="width" data-image-resizer-dimension-value="null"></span>
                  ×
                  <span data-image-resizer-dimension="height" data-image-resizer-dimension-value="null"></span>
                </div>
                <div class="editor-content-image" data-image="">
                  <img src="/path/to/logo.png" alt="Decidim logo">
                </div>
              </div>
            </div>
          `
        );
      });
    });
  });
});
