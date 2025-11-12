import Link from "@tiptap/extension-link";
import { Plugin, NodeSelection } from "prosemirror-state";

import { getDictionary } from "src/decidim/refactor/moved/i18n";
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
        class: null
      }
    }
  },

  renderHTML({ HTMLAttributes }) {
    const attrs = { ...HTMLAttributes };
    if (attrs.target === "") {
      Reflect.deleteProperty(attrs, "target");
    }
    return ["a", attrs, 0];
  },

  addCommands() {
    const i18n = getDictionary("editor.extensions.link");

    return {
      ...this.parent?.(),

      toggleLinkBubble: () => ({ dispatch }) => {
        const { selection } = this.editor.state;
        const isImageSelection = selection instanceof NodeSelection && selection.node.type.name === "image";
        const imageHasLink = isImageSelection && Boolean(selection.node.attrs.href);

        if (dispatch) {
          if (this.editor.isActive("link") || (isImageSelection && imageHasLink)) {
            this.storage.bubbleMenu.handleSelectionChange(this.editor.view);
            return true;
          }

          this.storage.bubbleMenu.hide();
          return false;
        }

        if (isImageSelection) {
          return imageHasLink;
        }

        return this.editor.isActive("link");
      },

      linkDialog: () => async ({ dispatch, commands }) => {
        if (dispatch) {
          const { state } = this.editor;
          const { selection } = state;
          const isImageSelection = selection instanceof NodeSelection && selection.node.type.name === "image";
          const nodeType = (() => {
            if (isImageSelection) {
              return "image";
            }
            return "link";
          })();

          if (!isImageSelection) {
            // If the cursor is within the link but the link is not selected, the
            // link would not be correctly updated. Also if only a part of the
            // link is selected, the link would be split to separate links, only
            // the current selection getting the updated link URL.
            commands.extendMarkRange("link");
          }

          this.storage.bubbleMenu.hide();

          const { allowTargetControl } = this.options;

          let href = null;
          let target = null;

          ({ href, target } = this.editor.getAttributes(nodeType));

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

          const buildChain = () => this.editor.chain().focus(null, { scrollIntoView: false });

          if (dialogState !== "save") {
            buildChain().toggleLinkBubble().run();
            return false;
          }

          if (!href || href.trim().length < 1) {
            if (isImageSelection) {
              return buildChain().updateAttributes("image", { href: null, target: null }).run();
            }
            return buildChain().unsetLink().run();
          }

          if (isImageSelection) {
            return buildChain().updateAttributes("image", { href: href, target }).toggleLinkBubble().run();
          }

          return buildChain().setLink({ href: href, target }).toggleLinkBubble().run();
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
