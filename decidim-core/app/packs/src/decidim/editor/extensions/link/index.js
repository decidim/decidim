import Link from "@tiptap/extension-link";
import { Plugin } from "prosemirror-state";

import { getDictionary } from "src/decidim/i18n";
import InputDialog from "src/decidim/editor/common/input_dialog";

export default Link.extend({
  addOptions() {
    return {
      ...this.parent?.(),
      allowTargetControl: false,
      HTMLAttributes: {
        target: "_blank",
        class: null
      }
    }
  },

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

          const { allowTargetControl } = this.options;

          let { href, target } = this.editor.getAttributes("link");

          const inputs = { href: { type: "text", label: i18n.hrefLabel } };
          if (allowTargetControl) {
            inputs.target = {
              type: "select",
              label: i18n.targetLabel,
              options: [
                { value: "", label: i18n["targets.default"] },
                { value: "_blank", label: i18n["targets.blank"] }
              ]
            }
          }

          const linkDialog = new InputDialog(this.editor, { inputs });
          const dialogState = await linkDialog.toggle({ href, target });
          href = linkDialog.getValue("href");
          target = linkDialog.getValue("target");
          if (!allowTargetControl) {
            target = "_blank";
          } else if (!target || target.length < 1) {
            target = null;
          }

          if (dialogState !== "save") {
            this.editor.commands.focus(null, { scrollIntoView: false });
            return false;
          }

          if (!href || href.trim().length < 1) {
            return this.editor.chain().focus(null, { scrollIntoView: false }).unsetLink().run();
          }

          return this.editor.chain().focus(null, { scrollIntoView: false }).setLink({ href, target }).run();
        }

        return true;
      }
    }
  },

  addProseMirrorPlugins() {
    const editor = this.editor;

    return [
      ...this.parent?.(),
      new Plugin({
        props: {
          handleDoubleClick() {
            if (!editor.isActive("link")) {
              return false;
            }

            editor.chain().focus().linkDialog().run();
            return true;
          }
        }
      })
    ];
  }
});
