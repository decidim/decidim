import Link from "@tiptap/extension-link";

import InputModal from "src/decidim/editor/input_modal";

export default Link.extend({
  addCommands() {
    return {
      ...this.parent?.(),
      linkModal: () => async ({ dispatch, commands }) => {
        if (dispatch) {
          // If the cursor is within the link but the link is not selected, the
          // link would not be correctly updated. Also if only a part of the
          // link is selected, the link would be split to separate links, only
          // the current selection getting the updated link URL.
          commands.extendMarkRange("link");

          let { href } = this.editor.getAttributes("link");

          const linkModal = new InputModal({
            inputs: { href: { label: "Please insert the link below" } },
            removeButton: true
          });
          const modalState = await linkModal.toggle({ href });
          href = linkModal.getValue("href");

          if (modalState !== "save" || !href || href.trim().length < 1) {
            return this.editor.chain().focus().unsetLink().run();
          }

          return this.editor.chain().focus().setLink({ href }).run();
        }

        return true;
      }
    }
  }
});
