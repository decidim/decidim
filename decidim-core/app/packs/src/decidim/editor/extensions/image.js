import { mergeAttributes } from "@tiptap/core";
import Image from "@tiptap/extension-image";
import { Plugin } from "prosemirror-state";

import { getDictionary } from "src/decidim/i18n";

const uploadImage = async (image, uploadUrl) => {
  const token = document.querySelector("meta[name='csrf-token']").getAttribute("content");

  const data = new FormData();
  data.append("image", image);

  const response = await fetch(uploadUrl, {
    method: "POST",
    mode: "cors",
    cache: "no-cache",
    headers: { "X-CSRF-Token": token },
    body: data
  });

  return response.json();
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

  addCommands() {
    const i18n = getDictionary("editor.extensions.image");

    return {
      ...this.parent?.(),
      imageModal: () => async ({ dispatch }) => {
        if (dispatch) {
          const { uploadModal } = this.options;
          let { src, alt } = this.editor.getAttributes("image");

          const modalState = await uploadModal.toggle({ src, alt }, {
            inputLabel: i18n.altLabel,
            uploadHandler: async (file) => uploadImage(file, this.options.uploadImagesPath)
          });
          if (modalState !== "save") {
            return false;
          }

          src = uploadModal.getValue("src");
          alt = uploadModal.getValue("alt");

          return this.editor.chain().setImage({ src, alt }).focus().run();
        }

        return true;
      }
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

        editor.commands.setImage({ src: imageData.url, alt: "" });
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
              const files = event?.dataTransfer?.files;
              if (!files || files.length < 1) {
                return;
              }

              const images = filterImages(files, contentTypes);
              if (images.length < 1) {
                return;
              }

              event.preventDefault();

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
