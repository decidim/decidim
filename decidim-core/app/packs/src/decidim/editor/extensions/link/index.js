import Link from "@tiptap/extension-link";
import { Plugin } from "prosemirror-state";

import { getDictionary } from "src/decidim/i18n";
import InputDialog from "src/decidim/editor/common/input_dialog";
import createBubbleMenu from "src/decidim/editor/extensions/link/bubble_menu";

export default Link.extend({
  addStorage() {
    return { bubbleMenu: null };
  },

  onCreate() {
    this.parent?.();

    this.storage.bubbleMenu = createBubbleMenu(this.editor);
  },

  onDestroy() {
    this.parent?.();

    this.storage.bubbleMenu.destroy();
    this.storage.bubbleMenu = null;
  },

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

      toggleLinkBubble: () => ({ dispatch }) => {
        if (dispatch) {
          if (this.editor.isActive("link")) {
            this.storage.bubbleMenu.show();
            return true;
          }

          this.storage.bubbleMenu.hide();
          return false;
        }
        return this.editor.isActive("link");
      },

      linkDialog: () => async ({ dispatch, commands }) => {
        if (dispatch) {
          // If the cursor is within the link but the link is not selected, the
          // link would not be correctly updated. Also if only a part of the
          // link is selected, the link would be split to separate links, only
          // the current selection getting the updated link URL.
          commands.extendMarkRange("link");

          this.storage.bubbleMenu.hide();

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
            this.editor.chain().focus(null, { scrollIntoView: false }).toggleLinkBubble().run();
            return false;
          }

          if (!href || href.trim().length < 1) {
            return this.editor.chain().focus(null, { scrollIntoView: false }).unsetLink().run();
          }

          return this.editor.chain().focus(null, { scrollIntoView: false }).setLink({ href, target }).toggleLinkBubble().run();
        }

        return true;
      }
    }
  },

  addProseMirrorPlugins() {
    const editor = this.editor;

    return [
      ...(this.parent?.() || {}),
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
