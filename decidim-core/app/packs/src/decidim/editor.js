/* eslint-disable require-jsdoc */

import lineBreakButtonHandler from "src/decidim/editor/linebreak_module";
import "src/decidim/editor/clipboard_override";
import "src/decidim/vendor/image-resize.min";
import "src/decidim/vendor/image-upload.min";

const quillFormats = [
  "bold",
  "italic",
  "link",
  "underline",
  "header",
  "list",
  "alt",
  "break",
  "width",
  "style",
  "code",
  "blockquote",
  "indent"
];

export default function createQuillEditor(container) {
  const toolbar = $(container).data("toolbar");
  const disabled = $(container).data("disabled");

  const allowedEmptyContentSelector = "iframe";
  let quillToolbar = [
    ["bold", "italic", "underline", "linebreak"],
    [{ list: "ordered" }, { list: "bullet" }],
    ["link", "clean"],
    ["code", "blockquote"],
    [{ indent: "-1" }, { indent: "+1" }]
  ];

  let addImage = false;
  let addVideo = false;

  /**
   * - basic = only basic controls without titles
   * - content = basic + headings
   * - full = basic + headings + image + video
   */
  if (toolbar === "content") {
    quillToolbar = [[{ header: [2, 3, 4, 5, 6, false] }], ...quillToolbar];
  } else if (toolbar === "full") {
    addImage = true;
    addVideo = true;
    quillToolbar = [
      [{ header: [2, 3, 4, 5, 6, false] }],
      ...quillToolbar,
      ["video"],
      ["image"]
    ];
  }

  let modules = {
    linebreak: {},
    toolbar: {
      container: quillToolbar,
      handlers: {
        linebreak: lineBreakButtonHandler
      }
    }
  };
  const $input = $(container).siblings('input[type="hidden"]');
  container.innerHTML = $input.val() || "";
  const token = $('meta[name="csrf-token"]').attr("content");

  if (addVideo) {
    quillFormats.push("video");
  }

  if (addImage) {
    // Attempt to allow images only if the image support is enabled at editor support.
    // see: https://github.com/quilljs/quill/issues/1108
    quillFormats.push("image");

    modules.imageResize = {
      modules: ["Resize", "DisplaySize"]
    };
    modules.imageUpload = {
      url: $(container).data("uploadImagesPath"),
      method: "POST",
      name: "image",
      withCredentials: false,
      headers: { "X-CSRF-Token": token },
      callbackOK: (serverResponse, next) => {
        $("div.ql-toolbar").last().removeClass("editor-loading");
        next(serverResponse.url);
      },
      callbackKO: (serverError) => {
        $("div.ql-toolbar").last().removeClass("editor-loading");
        console.log(`Image upload error: ${serverError.message}`);
      },
      checkBeforeSend: (file, next) => {
        $("div.ql-toolbar").last().addClass("editor-loading");
        next(file);
      }
    };

    const text = $(container).data("dragAndDropHelpText");
    $(container).after(
      `<p class="help-text" style="margin-top:-1.5rem;">${text}</p>`
    );
  }
  const quill = new Quill(container, {
    modules: modules,
    formats: quillFormats,
    theme: "snow"
  });

  if (addImage === false) {
    // Firefox natively implements image drop in contenteditable which is why we need to disable that
    quill.root.addEventListener("drop", (ev) => ev.preventDefault());
  }

  if (disabled) {
    quill.disable();
  }

  quill.on("text-change", () => {
    const text = quill.getText();

    // Triggers CustomEvent with the cursor position
    // It is required in input_mentions.js
    let event = new CustomEvent("quill-position", {
      detail: quill.getSelection()
    });
    container.dispatchEvent(event);

    if (
      (text === "\n" || text === "\n\n") &&
      quill.root.querySelectorAll(allowedEmptyContentSelector).length === 0
    ) {
      $input.val("");
    } else {
      const emptyParagraph = "<p><br></p>";
      const cleanHTML = quill.root.innerHTML.replace(
        new RegExp(`^${emptyParagraph}|${emptyParagraph}$`, "g"),
        ""
      );
      $input.val(cleanHTML);
    }
  });
  // After editor is ready, linebreak_module deletes two extraneous new lines
  quill.emitter.emit("editor-ready");

  return quill;
}
