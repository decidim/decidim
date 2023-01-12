import Link from "@tiptap/extension-link";

import { getDictionary } from "src/decidim/i18n";
import InputDialog from "src/decidim/editor/common/input_dialog";

export default Link.extend({
  addCommands() {
    const i18n = getDictionary("editor.extensions.link");

    return {
      ...this.parent?.(),
      linkDialog: () => async ({ dispatch, commands }) => {
        if (dispatch) {
          // If the cursor is within the link but the link is not selected, the
          // link would not be correctly updated. Also if only a part of the
          // link is selected, the link would be split to separate links, only
          // the current selection getting the updated link URL.
          commands.extendMarkRange("link");

          let { href, target } = this.editor.getAttributes("link");

          const linkDialog = new InputDialog(this.editor, {
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
          const dialogState = await linkDialog.toggle({ href, target });
          href = linkDialog.getValue("href");
          target = linkDialog.getValue("target");
          if (!target || target.length < 1) {
            target = null;
          }

          if (dialogState !== "save" || !href || href.trim().length < 1) {
            return this.editor.chain().focus(null, { scrollIntoView: false }).unsetLink().run();
          }

          return this.editor.chain().focus(null, { scrollIntoView: false }).setLink({ href, target }).run();
        }

        return true;
      }
    }
  }
});
