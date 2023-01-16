/* global jest */

import { createBasicEditor, updateContent, sleep, pasteContent } from "../helpers";

import Dialog from "../../extensions/dialog";
import VideoEmbed from "../../extensions/video_embed";

describe("VideoEmbed", () => {
  let editor = null;
  let editorElement = null;

  beforeEach(() => {
    document.body.innerHTML = "";

    editor = createBasicEditor({ extensions: [Dialog, VideoEmbed] })
    editorElement = editor.view.dom;

    // Append a dummy data-dialog element to the DOM so that the document is
    // recognized as "redesigned" by the input dialog.
    const dummy = document.createElement("div");
    dummy.dataset.dialog = "";
    document.body.append(dummy);
  });

  it("renders correctly", () => {
    editor.commands.setVideo({
      src: "https://www.youtube.com/watch?v=f6JMgJAQ2tc",
      title: "Decidim"
    });

    expect(editorElement.innerHTML).toMatchHtml(`
      <div class="editor-content-videoEmbed ProseMirror-selectednode" data-video-embed="https://www.youtube.com/watch?v=f6JMgJAQ2tc" draggable="true">
        <div>
          <iframe src="https://www.youtube-nocookie.com/embed/f6JMgJAQ2tc?cc_load_policy=1&amp;modestbranding=1" title="Decidim" frameborder="0" allowfullscreen="true"></iframe>
        </div>
      </div>
    `);
    expect(editor.getHTML()).toMatchHtml(`
      <div class="editor-content-videoEmbed" data-video-embed="https://www.youtube.com/watch?v=f6JMgJAQ2tc">
        <div>
          <iframe src="https://www.youtube-nocookie.com/embed/f6JMgJAQ2tc?cc_load_policy=1&amp;modestbranding=1" title="Decidim" frameborder="0" allowfullscreen="true"></iframe>
        </div>
      </div>
    `);
  });

  it("allows editing the selected video element", async () => {
    editorElement.focus();
    await updateContent(editorElement, `
      <div class="editor-content-videoEmbed" data-video-embed="https://www.youtube.com/watch?v=f6JMgJAQ2tc">
        <div>
          <iframe src="https://www.youtube-nocookie.com/embed/f6JMgJAQ2tc?cc_load_policy=1&amp;modestbranding=1" title="Decidim" frameborder="0" allowfullscreen="true"></iframe>
        </div>
      </div>
    `);

    editor.commands.setVideo({
      src: "https://www.youtube.com/watch?v=zhMMW0TENNA",
      title: "Free Open-Source"
    });

    expect(editorElement.innerHTML).toMatchHtml(`
      <div class="editor-content-videoEmbed ProseMirror-selectednode" data-video-embed="https://www.youtube.com/watch?v=zhMMW0TENNA" draggable="true">
        <div>
          <iframe src="https://www.youtube-nocookie.com/embed/zhMMW0TENNA?cc_load_policy=1&amp;modestbranding=1" title="Free Open-Source" frameborder="0" allowfullscreen="true"></iframe>
        </div>
      </div>
    `);
    expect(editor.getHTML()).toMatchHtml(`
      <div class="editor-content-videoEmbed" data-video-embed="https://www.youtube.com/watch?v=zhMMW0TENNA">
        <div>
          <iframe src="https://www.youtube-nocookie.com/embed/zhMMW0TENNA?cc_load_policy=1&amp;modestbranding=1" title="Free Open-Source" frameborder="0" allowfullscreen="true"></iframe>
        </div>
      </div>
    `);
  });

  it("allows setting the video through the dialog", async () => {
    editorElement.focus();
    await updateContent(editorElement, `
      <div class="editor-content-videoEmbed" data-video-embed="https://www.youtube.com/watch?v=f6JMgJAQ2tc">
        <div>
          <iframe src="https://www.youtube-nocookie.com/embed/f6JMgJAQ2tc?cc_load_policy=1&amp;modestbranding=1" title="Decidim" frameborder="0" allowfullscreen="true"></iframe>
        </div>
      </div>
    `);

    editor.commands.videoEmbedDialog();
    expect(editorElement.classList.contains("dialog-open")).toBe(true);

    const dialog = document.querySelector("[data-dialog][aria-hidden='false']");
    dialog.querySelector("[data-input='src'] input").value = "https://www.youtube.com/watch?v=f6JMgJAQ2tc";
    dialog.querySelector("[data-input='title'] input").value = "Decidim";
    dialog.querySelector("[data-dialog-actions] button[data-action='save']").click();
    await sleep(50);

    expect(editor.getHTML()).toMatchHtml(`
      <div class="editor-content-videoEmbed" data-video-embed="https://www.youtube.com/watch?v=f6JMgJAQ2tc">
        <div>
          <iframe src="https://www.youtube-nocookie.com/embed/f6JMgJAQ2tc?cc_load_policy=1&amp;modestbranding=1" title="Decidim" frameborder="0" allowfullscreen="true"></iframe>
        </div>
      </div>
    `);
  });

  it("allows updating the video through the dialog", async () => {
    editor.commands.videoEmbedDialog();
    expect(editorElement.classList.contains("dialog-open")).toBe(true);

    const dialog = document.querySelector("[data-dialog][aria-hidden='false']");
    dialog.querySelector("[data-input='src'] input").value = "https://www.youtube.com/watch?v=zhMMW0TENNA";
    dialog.querySelector("[data-input='title'] input").value = "Free Open-Source";
    dialog.querySelector("[data-dialog-actions] button[data-action='save']").click();
    await sleep(50);

    expect(editor.getHTML()).toMatchHtml(`
      <div class="editor-content-videoEmbed" data-video-embed="https://www.youtube.com/watch?v=zhMMW0TENNA">
        <div>
          <iframe src="https://www.youtube-nocookie.com/embed/zhMMW0TENNA?cc_load_policy=1&amp;modestbranding=1" title="Free Open-Source" frameborder="0" allowfullscreen="true"></iframe>
        </div>
      </div>
    `);
  });

  it("allows pasting a YouTube video", async () => {
    await pasteContent(editorElement, "https://www.youtube.com/watch?v=f6JMgJAQ2tc");

    expect(editor.getHTML()).toMatchHtml(`
      <div class="editor-content-videoEmbed" data-video-embed="https://www.youtube.com/watch?v=f6JMgJAQ2tc">
        <div>
          <iframe src="https://www.youtube-nocookie.com/embed/f6JMgJAQ2tc?cc_load_policy=1&amp;modestbranding=1" title="" frameborder="0" allowfullscreen="true"></iframe>
        </div>
      </div>
    `);
  });

  it("allows pasting a Vimeo video", async () => {
    await pasteContent(editorElement, "https://vimeo.com/312909656");

    expect(editor.getHTML()).toMatchHtml(`
      <div class="editor-content-videoEmbed" data-video-embed="https://vimeo.com/312909656">
        <div>
          <iframe src="https://player.vimeo.com/video/312909656" title="" frameborder="0" allowfullscreen="true"></iframe>
        </div>
      </div>
    `);
  });

  it("allows double clicking the video embed", async () => {
    editorElement.focus();
    await updateContent(editorElement, `
      <div class="editor-content-videoEmbed" data-video-embed="https://www.youtube.com/watch?v=f6JMgJAQ2tc">
        <div>
          <iframe src="https://www.youtube-nocookie.com/embed/f6JMgJAQ2tc?cc_load_policy=1&amp;modestbranding=1" title="Decidim" frameborder="0" allowfullscreen="true"></iframe>
        </div>
      </div>
    `);

    // Position calculations do not work with JSDom / Jest
    editor.view.posAtCoords = jest.fn().mockReturnValue({ pos: 1, inside: -1 });

    editorElement.dispatchEvent(new MouseEvent("mousedown", { clientX: 10, clientY: 10 }));
    editorElement.dispatchEvent(new MouseEvent("mousedown", { clientX: 10, clientY: 10 }));
    await sleep(0);

    expect(editorElement.classList.contains("dialog-open")).toBe(true);

    const dialog = document.querySelector("[data-dialog][aria-hidden='false']");
    expect(dialog).toBeInstanceOf(HTMLDivElement);

    dialog.querySelector("[data-input='src'] input").value = "https://www.youtube.com/watch?v=zhMMW0TENNA";
    dialog.querySelector("[data-dialog-actions] button[data-action='save']").click();
    await sleep(50);

    expect(editor.getHTML()).toMatchHtml(`
      <div class="editor-content-videoEmbed" data-video-embed="https://www.youtube.com/watch?v=zhMMW0TENNA">
        <div>
          <iframe src="https://www.youtube-nocookie.com/embed/zhMMW0TENNA?cc_load_policy=1&amp;modestbranding=1" title="Decidim" frameborder="0" allowfullscreen="true"></iframe>
        </div>
      </div>
    `);
  });
});
