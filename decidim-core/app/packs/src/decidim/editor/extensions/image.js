import { mergeAttributes } from "@tiptap/core";
import Image from "@tiptap/extension-image";
import { Plugin } from "prosemirror-state";
import { DOMSerializer } from "prosemirror-model";

import { getDictionary } from "src/decidim/i18n";
import { fileNameToTitle } from "src/decidim/editor/utilities/file";

const uploadImage = async (image, uploadUrl) => {
  const token = document.querySelector("meta[name='csrf-token']").getAttribute("content");

  const data = new FormData();
  data.append("image", image);

  const i18n = getDictionary("editor.extensions.image");

  return new Promise((resolve, reject) => {
    fetch(uploadUrl, {
      method: "POST",
      mode: "cors",
      cache: "no-cache",
      headers: { "X-CSRF-Token": token },
      body: data
    }).then((response) => {
      return new Promise((responseResolve, responseReject) => {
        if (response.ok) {
          response.json().then(responseResolve).catch(responseReject);
        } else {
          responseResolve({ message: i18n.uploadError });
        }
      });
    }).then(
      (json) => resolve({ title: fileNameToTitle(image.name), ...json })
    ).catch(reject);
  });
}

const filterImages = (files, contentTypes) => {
  return Array.from(files).filter(
    (file) => {
      if (contentTypes instanceof RegExp) {
        return contentTypes.test(file.type)
      } else if (contentTypes instanceof Array) {
        return contentTypes.includes(file.type);
      }
      // string
      return contentTypes === file.type;
    }
  );
}

/**
 * Handles the image uploads through ActiveStorage when they are dropped or
 * pasted to the editor.
 *
 * Paste and drop handling based on:
 * https://gist.github.com/slava-vishnyakov/16076dff1a77ddaca93c4bccd4ec4521
 */
export default Image.extend({
  addOptions() {
    return {
      ...this.parent?.(),
      contentTypes: /^image\/(jpe?g|png|svg|webp)$/i,
      uploadImagesPath: null,
      uploadModal: null
    };
  },

  addAttributes() {
    return {
      ...this.parent?.(),
      width: { default: null }
    };
  },

  addCommands() {
    const i18n = getDictionary("editor.extensions.image");

    return {
      ...this.parent?.(),
      imageModal: () => async ({ dispatch }) => {
        if (dispatch) {
          const { uploadModal } = this.options;
          let { src, alt, width } = this.editor.getAttributes("image");

          const modalState = await uploadModal.toggle({ src, alt }, {
            inputLabel: i18n.altLabel,
            uploadHandler: async (file) => uploadImage(file, this.options.uploadImagesPath)
          });
          if (modalState !== "save") {
            return false;
          }

          if (uploadModal.getValue("src") !== src) {
            // Reset the width to original width in case the image changed.
            width = null;
          }

          src = uploadModal.getValue("src");
          alt = uploadModal.getValue("alt");

          return this.editor.chain().setImage({ src, alt, width }).focus().run();
        }

        return true;
      }
    }
  },

  /**
   * Wraps the editor elemnet around the resizable element and implements the
   * resizer functionality.
   *
   * @returns {Object} The custom node view
   */
  addNodeView() {
    const createControl = (position) => {
      const el = document.createElement("div");
      el.dataset.imageResizerControl = position;
      return el;
    };

    return ({ editor, node }) => {
      const resizer = document.createElement("div");
      resizer.dataset.imageResizerWrapper = "";
      resizer.append(createControl("top-left"));
      resizer.append(createControl("top-right"));
      resizer.append(createControl("bottom-left"));
      resizer.append(createControl("bottom-right"));

      const contentDOM = DOMSerializer.fromSchema(node.type.schema).serializeNode(node);
      resizer.append(contentDOM);

      const img = contentDOM.querySelector("img");
      let activeResizeControl = null,
          currentWidth = null,
          originalWidth = null,
          resizeStartPosition = null;
      document.addEventListener("mousemove", (ev) => {
        if (!activeResizeControl) {
          return;
        }

        let diff = resizeStartPosition - ev.clientX;
        if (activeResizeControl.match(/-left$/)) {
          diff *= -1;
        }

        currentWidth = Math.round(originalWidth * (1 - diff / originalWidth));
        if (currentWidth < 100) {
          currentWidth = 100;
        } else if (currentWidth >= img.naturalWidth) {
          currentWidth = null;
        }

        editor.commands.updateAttributes("image", { width: currentWidth });
      });
      document.addEventListener("mouseup", () => {
        activeResizeControl = resizeStartPosition = null;
      });
      resizer.querySelectorAll("[data-image-resizer-control]").forEach((ctrl) => {
        ctrl.addEventListener("mousedown", (ev) => {
          if (!editor.isEditable) {
            return;
          }

          ev.preventDefault();
          activeResizeControl = ctrl.dataset.imageResizerControl;
          originalWidth = editor.getAttributes("image").width || img.naturalWidth;
          resizeStartPosition = ev.clientX;
        });
      });

      const dom = document.createElement("div");
      dom.dataset.imageResizer = "";
      dom.append(resizer);

      return {
        dom,
        contentDOM,
        update: (updatedNode) => {
          if (updatedNode.type !== this.type) {
            return false;
          }
          const { alt, src, title, width } = updatedNode.attrs;

          img.alt = alt;
          if (activeResizeControl === null && img.src !== src) {
            img.src = src;
          }
          if (title) {
            img.title = title;
          } else {
            img.removeAttribute("title");
          }
          if (width) {
            img.width = width;
          } else {
            img.removeAttribute("width");
          }

          return true;
        }
      };
    }
  },

  parseHTML() {
    return [{ tag: "div[data-image] img[src]:not([src^='data:'])" }];
  },

  renderHTML({ HTMLAttributes }) {
    return [
      "div",
      { "class": "editor-content-image", "data-image": "" },
      [
        "img",
        mergeAttributes(this.options.HTMLAttributes, HTMLAttributes)
      ]
    ];
  },

  addProseMirrorPlugins() {
    const editor = this.editor;
    const { uploadImagesPath, contentTypes } = this.options;

    const handleUploadedImages = (uploadedImages) => {
      uploadedImages.forEach((imageData) => {
        if (!imageData.url) {
          return;
        }

        editor.commands.setImage({ src: imageData.url, alt: imageData.title });
      });
    }

    return [
      new Plugin({
        props: {
          handlePaste(view, event) {
            const items = (event.clipboardData || event.originalEvent.clipboardData).items;
            const images = filterImages(items, contentTypes);
            if (images.length < 1) {
              return;
            }

            Promise.all(images.map((item) => uploadImage(item.getAsFile(), uploadImagesPath))).then((uploadedImages) => {
              handleUploadedImages(uploadedImages);
            });
          },

          handleDoubleClick() {
            if (!editor.isActive("image")) {
              return false;
            }

            editor.chain().focus().imageModal().run();
            return true;
          },

          handleDOMEvents: {
            drop(view, event) {
              const position = view.posAtCoords({left: event.clientX, top: event.clientY});

              const files = event?.dataTransfer?.files;
              if (!files || files.length < 1) {
                return;
              }

              const images = filterImages(files, contentTypes);
              if (images.length < 1) {
                return;
              }

              event.preventDefault();

              // Make sure the image is dropped at the right place. Otherwise
              // the image would appear at the current text selection position
              // and always in the beginning of the content in case the editor
              // did not have focus when the image was dropped.
              editor.chain().focus().setTextSelection(position.pos).run();

              Promise.all(images.map((image) => uploadImage(image, uploadImagesPath))).then((uploadedImages) => {
                handleUploadedImages(uploadedImages);
              });
            }
          }
        }
      })
    ];
  }
});
