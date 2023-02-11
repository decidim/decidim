import { isNodeSelection, posToDOMRect } from "@tiptap/core";
import { Plugin } from "prosemirror-state";
import tippy from "tippy.js";

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
 * A custom bubble menu based on `@tiptap/extension-bubble-menu`.
 *
 * This has been customized for this purpose in order to support the use case
 * better and due to some weird behavior in the original extension. This allows
 * us to control also externally when to show and hide the bubble menu instead
 * of leaving it up to the Tiptap extension which does not recognize all the
 * events, such as opening or closing a dialog.
 *
 * The actual bubble menu implementations can implement the following methods by
 * extending this class:
 * - `shouldDisplay()` - defines when the bubble menu is displayed by returning
 *   a boolean indicating the display status, returns `false` by default
 * - `display()` - called when the bubble menu is displayed allowing any updates
 *   to the bubble element by the implementation
 * - `handleAction()` - called when any button within the bubble menu is clicked
 */
export default class BubbleMenu {
  constructor({ editor, element, pluginKey }) {
    this.editor = editor;

    this.element = element;
    this.element.querySelectorAll("button").forEach((el) => {
      const action = el.dataset.action;
      el.addEventListener("click", (ev) => {
        ev.preventDefault();
        this.handleAction(action);
      });
    });

    this.tippy = createTippy(this.editor.view.dom, this.element);

    this.plugin = createProseMirrorPlugin(pluginKey, this);
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
    if (this.shouldDisplay(view)) {
      this.updatePosition(view);
      this.display(view);

      this.show();
      return;
    }
    this.hide();
  }

  shouldDisplay() {
    // This can be overridden by the implementation
    return false;
  }

  display() {
    // This can be overridden by the implementation
  }

  handleAction() {
    // This can be overridden by the implementation
  }

  updatePosition(view) {
    const { state } = view;
    const { ranges } = state.selection;
    const from = Math.min(...ranges.map((range) => range.$from.pos));
    const to = Math.max(...ranges.map((range) => range.$to.pos));

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
