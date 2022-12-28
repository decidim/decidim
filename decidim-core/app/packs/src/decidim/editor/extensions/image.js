import { mergeAttributes } from "@tiptap/core";
import Image from "@tiptap/extension-image";
import { Plugin } from "prosemirror-state";

import InputModal from "src/decidim/editor/input_modal";

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

const filterImages = (files) => {
  return Array.from(files).filter(
    (file) => (/^image\/(jpe?g|png|svg|webp)$/i).test(file.type)
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
      uploadImagesPath: null
    }
  },

  addCommands() {
    return {
      ...this.parent?.(),
      imageModal: () => async ({ dispatch }) => {
        if (dispatch) {
          const imageModal = new InputModal({
            inputs: {
              src: { label: "Please insert the image URL below" },
              alt: { label: "Please provide an alternative text for the image" }
            }
          });
          let { src, alt } = this.editor.getAttributes("image");

          const modalState = await imageModal.toggle({ src, alt });
          if (modalState !== "save") {
            return false;
          }

          src = imageModal.getValue("src");
          alt = imageModal.getValue("alt");

          return this.editor.chain().setImage({ src, alt }).focus().run();
        }

        return true;
      }
    }
  },

  parseHTML() {
    return [{ tag: "p[data-image] img[src]:not([src^='data:'])" }]
  },

  renderHTML({ HTMLAttributes }) {
    return [
      "p",
      { "data-image": "" },
      [
        "img",
        mergeAttributes(this.options.HTMLAttributes, HTMLAttributes)
      ]
    ]
  },

  addProseMirrorPlugins() {
    const editor = this.editor;
    const { uploadImagesPath } = this.options;

    return [
      new Plugin({
        props: {
          handlePaste(view, event) {
            const items = (event.clipboardData || event.originalEvent.clipboardData).items;
            const images = filterImages(items);
            if (images.length < 1) {
              return;
            }

            Promise.all(images.map((item) => uploadImage(item.getAsFile(), uploadImagesPath))).then((uploadedImages) => {
              uploadedImages.forEach((imageData) => {
                editor.commands.setImage({ src: imageData.url, alt: "" });
              });
            });
          },

          handleDoubleClick(view) {
            const node = view.state.selection.node;
            if (node?.type?.name !== "image") {
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

              const images = filterImages(files);
              if (images.length < 1) {
                return;
              }

              event.preventDefault();

              Promise.all(images.map((image) => uploadImage(image, uploadImagesPath))).then((uploadedImages) => {
                uploadedImages.forEach((imageData) => {
                  editor.commands.setImage({ src: imageData.url, alt: "" });
                });
              });
            }
          }
        }
      })
    ];
  }
});
