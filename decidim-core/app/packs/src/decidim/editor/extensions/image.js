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
      imageModal: () => async ({ dispatch, state }) => {
        if (dispatch) {
          let node = state.selection.node;
          if (node?.type?.name !== "image") {
            node = null;
          }

          const imageModal = new InputModal({
            inputs: {
              src: { label: "Please insert the image URL below" },
              alt: { label: "Please provide an alternative text for the image" }
            }
          });
          let src = node?.attrs?.src;
          let alt = node?.attrs?.alt;

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

            const { schema } = view.state;

            Promise.all(images.map((item) => uploadImage(item.getAsFile(), uploadImagesPath))).then((uploadedImages) => {
              uploadedImages.forEach((imageData) => {
                const node = schema.nodes.image.create({ src: imageData.url, alt: "" });
                const transaction = view.state.tr.replaceSelectionWith(node);
                view.dispatch(transaction)
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

              const { schema } = view.state;
              const coordinates = view.posAtCoords({ left: event.clientX, top: event.clientY });

              Promise.all(images.map((image) => uploadImage(image, uploadImagesPath))).then((uploadedImages) => {
                uploadedImages.forEach((imageData) => {
                  const node = schema.nodes.image.create({ src: imageData.url, alt: "" });
                  const transaction = view.state.tr.insert(coordinates.pos, node);
                  view.dispatch(transaction);
                });
              });
            }
          }
        }
      })
    ];
  }
});
