import { isNodeSelection, posToDOMRect } from "@tiptap/core";
import { Plugin } from "prosemirror-state";

const createBubbleRoot = (content) => {
  const root = document.createElement("div");
  root.style.cssText = `
    z-index: 9999;
    position: absolute;
    visibility: hidden;
    inset: 0 auto auto 0;
    margin: 0;
  `;
  root.dataset.bubbleMenu = "";
  root.append(content);

  return root;
}

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

    this.bubble = createBubbleRoot(this.element);
    this.bubbleShown = false;

    this.plugin = createProseMirrorPlugin(pluginKey, this);
    this.editor.registerPlugin(this.plugin);
  }

  show() {
    if (this.bubbleShown) {
      return;
    }
    this.editor.view.dom.parentElement.append(this.bubble);
    this.bubble.style.visibility = "visible";
    this.bubbleShown = true;
  }

  hide() {
    if (!this.bubbleShown) {
      return;
    }
    this.bubble.style.visibility = "hidden";
    this.bubble.remove();
    this.bubbleShown = false;
  }

  destroy() {
    this.hide();
    this.bubble = null;
    this.editor.unregisterPlugin(this.plugin.key);
  }

  handleSelectionChange(view) {
    if (this.editor.commands.isDialogOpen()) {
      this.hide();
      return;
    }
    if (this.shouldDisplay(view)) {
      this.display(view);
      this.show();
      this.updatePosition(view);

      return;
    }
    this.hide();
  }

  getReferenceRect(view) {
    const { state } = view;
    const { ranges } = state.selection;
    const from = Math.min(...ranges.map((range) => range.$from.pos));
    const to = Math.max(...ranges.map((range) => range.$to.pos));

    if (isNodeSelection(state.selection)) {
      const node = view.nodeDOM(from);
      if (node) {
        return node.getBoundingClientRect();
      }
    }

    return posToDOMRect(view, from, to);
  }

  updatePosition(view) {
    const editorRect = view.dom.getBoundingClientRect();
    const referenceRect = this.getReferenceRect(view);

    const xDiff = referenceRect.left - editorRect.left;
    const yDiff = referenceRect.top - editorRect.top;
    const width = this.bubble.clientWidth;
    const height = this.bubble.clientHeight;

    let xPos = Math.round(xDiff - width / 2);
    if (xPos < 5) {
      xPos = 5;
    }

    let yPos = Math.round(yDiff + height - 5);
    if (yPos < 5) {
      yPos = 5;
    }

    this.bubble.style.transform = `translate(${xPos}px, ${yPos}px)`;
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
}
