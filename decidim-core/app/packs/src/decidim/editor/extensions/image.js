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
 * Based on:
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
      imageModal: (node) => async ({ view, dispatch, state, commands }) => {
        if (dispatch) {
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

          // Note that `commands.setImage(...)` won't work here because
          // apparently TipTap does not understand the async behavior of the
          // command, so we need to manually dispatch the change.
          const position = state.selection.anchor;
          if (node) {
            const transaction = state.tr.setNodeMarkup(position, null, { src, alt });
            view.dispatch(transaction);
          } else {
            const imageNode = state.schema.nodes.image.create({ src, alt });
            const transaction = state.tr.insert(position, imageNode);
            view.dispatch(transaction);
          }

          commands.focus();
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
            if (node.type.name !== "image") {
              return false;
            }

            editor.chain().focus().imageModal(node).run();
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
