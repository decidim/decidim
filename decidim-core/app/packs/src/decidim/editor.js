/* eslint-disable require-jsdoc */

import lineBreakButtonHandler from "src/decidim/editor/linebreak_module"
import "src/decidim/vendor/image-resize.min"
import "src/decidim/vendor/image-upload.min"

const quillFormats = ["bold", "italic", "link", "underline", "header", "list", "video", "image", "alt", "break"];

export default function createQuillEditor(container) {
  const toolbar = $(container).data("toolbar");
  const disabled = $(container).data("disabled");

  let quillToolbar = [
    ["bold", "italic", "underline", "linebreak"],
    [{ list: "ordered" }, { list: "bullet" }],
    ["link", "clean"]
  ];

  let addImage = $(container).data("editorImages");

  if (toolbar === "full") {
    quillToolbar = [
      [{ header: [1, 2, 3, 4, 5, 6, false] }],
      ...quillToolbar,
      ["video"]
    ];
  } else if (toolbar === "basic") {
    quillToolbar = [
      ...quillToolbar,
      ["video"]
    ];
  }

  if (addImage) {
    quillToolbar.push(["image"]);
  }

  let modules = {
    linebreak: {},
    toolbar: {
      container: quillToolbar,
      handlers: {
        "linebreak": lineBreakButtonHandler
      }
    }
  };
  const $input = $(container).siblings('input[type="hidden"]');
  container.innerHTML = $input.val() || "";
  const token = $('meta[name="csrf-token"]').attr("content");

  if(addImage) {
    modules.imageResize = {
      modules: ["Resize", "DisplaySize"]
    }
    modules.imageUpload = {
      url: $(container).data("uploadImagesPath"), // server url. If the url is empty then the base64 returns
      method: "POST", // change query method, default "POST"
      name: "image", // custom form name
      withCredentials: false, // withCredentials
      headers: { "X-CSRF-Token": token }, // add custom headers, example { token: "your-token"}
      // personalize successful callback and call next function to insert new url to the editor
      callbackOK: (serverResponse, next) => {
        $(quill.getModule("toolbar").container).last().removeClass("editor-loading")
        next(serverResponse.url);
      },
      // personalize failed callback
      callbackKO: serverError => {
        $(quill.getModule("toolbar").container).last().removeClass("editor-loading")
        alert(serverError.message);
      },
      checkBeforeSend: (file, next) => {
        $(quill.getModule("toolbar").container).last().addClass("editor-loading")
        next(file); // go back to component and send to the server
      }
    }
  }

  const quill = new Quill(container, {
    modules: modules,
    formats: quillFormats,
    theme: "snow"
  });

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

    if (text === "\n" || text === "\n\n") {
      $input.val("");
    } else {
      $input.val(quill.root.innerHTML);
    }
  });
  // After editor is ready, linebreak_module deletes two extraneous new lines
  quill.emitter.emit("editor-ready");

  if(addImage) {
    const t = $(container).data("dragAndDropHelpText");
    $(container).after(`<p class="help-text" style="margin-top:-1.5rem;">${t}</p>`);
  }

  // After editor is ready, linebreak_module deletes two extraneous new lines
  quill.emitter.emit("editor-ready");

  return quill;
}
