import Link from "@tiptap/extension-link";

import InputModal from "src/decidim/editor/input_modal";

export default Link.extend({
  addOptions() {
    return {
      ...this.parent?.(),
      i18n: {
        hrefLabel: "Link URL",
        targetLabel: "Target",
        targets: { blank: "New tab", default: "Default (same tab)" }
      }
    };
  },

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

          const { i18n } = this.options;
          let { href, target } = this.editor.getAttributes("link");

          const linkModal = new InputModal({
            inputs: {
              href: { type: "text", label: i18n.hrefLabel },
              target: {
                type: "select",
                label: i18n.targetLabel,
                options: [
                  { value: "", label: i18n["targets.default"] },
                  { value: "_blank", label: i18n["targets.blank"] }
                ]
              }
            },
            removeButton: true
          });
          const modalState = await linkModal.toggle({ href, target });
          href = linkModal.getValue("href");
          target = linkModal.getValue("target");
          if (target && target.length < 1) {
            target = null;
          }

          if (modalState !== "save" || !href || href.trim().length < 1) {
            return this.editor.chain().focus().unsetLink().run();
          }

          return this.editor.chain().focus().setLink({ href, target }).run();
        }

        return true;
      }
    }
  }
});
