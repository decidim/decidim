import { isNodeSelection, posToDOMRect } from "@tiptap/core";
import { Plugin, PluginKey } from "prosemirror-state";
import tippy from "tippy.js";

import { getDictionary } from "src/decidim/i18n";

const createElement = () => {
  const i18n = getDictionary("editor.extensions.link.bubbleMenu");

  const element = document.createElement("div");
  element.dataset.linkbubble = "";
  element.innerHTML = `
    <span data-linkbubble-content>
      ${i18n.url}:
      <span data-linkbubble-value></span>
    </span>
    <span data-linkbubble-actions>
      <button type="button" data-action="edit">${i18n.edit}</button>
      <button type="button" data-action="remove">${i18n.remove}</button>
    </span>
  `;

  return element;
};

const createTippy = (editorElement, content) => {
  return tippy(editorElement, {
    duration: 0,
    getReferenceClientRect: null,
    interactive: true,
    trigger: "manual",
    placement: "bottom",
    hideOnClick: "toggle",
    appendTo: editorElement.parentElement,
    aria: { expanded: null },
    content
  });
};

const createProseMirrorPlugin = (pluginKey, bubbleMenu) => {
  return new Plugin({
    key: pluginKey,
    view () {
      return {
        update: function (view, prevState) {
          const state = view.state;
          if (prevState && prevState.doc.eq(state.doc) && prevState.selection.eq(state.selection)) {
            return;
          }

          bubbleMenu.handleSelectionChange(view);
        }
      }
    }
  })
};

/**
 * A custom bubble menu for the links based on `@tiptap/extension-bubble-menu`.
 *
 * This has been customized for this purpose in order to support the use case
 * better and due to some weird behavior in the original extension. This allows
 * us to control also externally when to show and hide the bubble menu instead
 * of leaving it up to the Tiptap extension which does not recognize all the
 * events, such as opening or closing the link dialog.
 */
export default class BubbleMenu {
  constructor(editor) {
    this.editor = editor;

    this.element = createElement();
    this.element.querySelectorAll("button").forEach((el) => {
      const action = el.dataset.action;
      el.addEventListener("click", (ev) => {
        ev.preventDefault();
        if (action === "remove") {
          this.editor.chain().focus(null, { scrollIntoView: false }).unsetLink().run();
        } else {
          this.editor.commands.linkDialog();
        }
      });
    });

    this.tippy = createTippy(this.editor.view.dom, this.element);

    this.plugin = createProseMirrorPlugin(new PluginKey("LinkBubble"), this);
    this.editor.registerPlugin(this.plugin);
  }

  show() {
    this.tippy.show();
  }

  hide() {
    this.tippy.hide();
  }

  destroy() {
    this.tippy.destroy();
    this.editor.unregisterPlugin(this.plugin.key);
  }

  handleSelectionChange(view) {
    if (this.editor.commands.isDialogOpen()) {
      this.hide();
      return;
    }
    if (this.editor.isActive("link")) {
      this.updatePosition(view);

      const { href } = this.editor.getAttributes("link");
      this.element.querySelector("[data-linkbubble-value]").textContent = href;

      this.show();
      return;
    }
    this.hide();
  }

  updatePosition(view) {
    const { state } = view;
    const { ranges } = state.selection;
    const from = Math.min(...ranges.map((range) => range.$from.pos))
    const to = Math.max(...ranges.map((range) => range.$to.pos))

    this.tippy.setProps({
      getReferenceClientRect: () => {
        if (isNodeSelection(state.selection)) {
          const node = view.nodeDOM(from);
          if (node) {
            return node.getBoundingClientRect();
          }
        }

        return posToDOMRect(view, from, to);
      }
    });
  }
}
