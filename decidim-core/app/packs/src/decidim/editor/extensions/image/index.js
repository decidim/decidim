import { mergeAttributes } from "@tiptap/core";
import Image from "@tiptap/extension-image";
import { Plugin } from "prosemirror-state";

import { getDictionary } from "src/decidim/i18n";
import { fileNameToTitle } from "src/decidim/editor/utilities/file";
import createNodeView from "src/decidim/editor/extensions/image/node_view";

import UploadDialog from "src/decidim/editor/common/upload_dialog";

const createImageUploadDialog = (editor, { uploadDialogSelector }) => {
  const i18nUpload = getDictionary("editor.upload");
  return new UploadDialog(
    document.querySelector(uploadDialogSelector),
    {
      i18n: i18nUpload,
      onOpen: () => editor.commands.toggleDialog(true),
      onClose: () => editor.chain().toggleDialog(false).focus(null, { scrollIntoView: false }).run()
    }
  );
}

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
      if (response.ok) {
        return response.json();
      }
      return new Promise((responseResolve) => responseResolve({ message: i18n.uploadError }));
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
      uploadDialogSelector: null
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
    const uploadDialog = createImageUploadDialog(this.editor, this.options);

    return {
      ...this.parent?.(),
      imageDialog: () => async ({ dispatch }) => {
        if (dispatch) {
          let { src, alt, width } = this.editor.getAttributes("image");

          this.editor.commands.toggleDialog(true);
          const dialogState = await uploadDialog.toggle({ src, alt }, {
            inputLabel: i18n.altLabel,
            uploadHandler: async (file) => uploadImage(file, this.options.uploadImagesPath)
          });
          this.editor.commands.toggleDialog(false);

          if (dialogState !== "save") {
            this.editor.commands.focus(null, { scrollIntoView: false });
            return false;
          }

          if (uploadDialog.getValue("src") !== src) {
            // Reset the width to original width in case the image changed.
            width = null;
          }

          src = uploadDialog.getValue("src");
          alt = uploadDialog.getValue("alt");

          return this.editor.chain().setImage({ src, alt, width }).focus(null, { scrollIntoView: false }).run();
        }

        return true;
      }
    }
  },

  addNodeView() {
    return createNodeView(this);
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
              return false;
            }

            Promise.all(images.map((item) => uploadImage(item.getAsFile(), uploadImagesPath))).then((uploadedImages) => {
              handleUploadedImages(uploadedImages);
            });

            return true;
          },

          handleDoubleClick() {
            if (!editor.isActive("image")) {
              return false;
            }

            editor.chain().focus().imageDialog().run();
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
