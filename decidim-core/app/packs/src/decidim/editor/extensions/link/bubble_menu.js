import { PluginKey } from "prosemirror-state";

import { getDictionary } from "src/decidim/i18n";
import BubbleMenu from "src/decidim/editor/common/bubble_menu";

class LinkBubbleMenu extends BubbleMenu {
  shouldDisplay() {
    return this.editor.isActive("link");
  }

  display() {
    const { href } = this.editor.getAttributes("link");
    this.element.querySelector("[data-linkbubble-value]").textContent = href;
  }

  handleAction(action) {
    if (action === "remove") {
      this.editor.chain().focus(null, { scrollIntoView: false }).unsetLink().run();
    } else {
      this.editor.commands.linkDialog();
    }
  }
}

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

export default (editor) => {
  return new LinkBubbleMenu({
    editor,
    element: createElement(),
    pluginKey: new PluginKey("LinkBubble")
  });
};
