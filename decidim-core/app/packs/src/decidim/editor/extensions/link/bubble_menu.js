import { NodeSelection, PluginKey } from "prosemirror-state";

import { getDictionary } from "src/decidim/refactor/moved/i18n";
import BubbleMenu from "src/decidim/editor/common/bubble_menu";

class LinkBubbleMenu extends BubbleMenu {
  shouldDisplay(view) {
    if (this.editor.isActive("link")) {
      return true;
    }

    const selection = view.state.selection;
    return this.isImage(selection) && Boolean(selection.node.attrs.href);
  }

  display(view) {
    if (this.editor.isActive("link")) {
      const { href } = this.editor.getAttributes("link");
      this.updateHref(href);
      return;
    }

    const selection = view.state.selection;
    if (this.isImage(selection)) {
      this.bubble.style.zIndex = "10";
      this.updateHref(selection.node.attrs.href);
    }
  }

  handleAction(action) {
    if (action === "remove") {
      const { selection } = this.editor.state;
      if (this.isImage(selection)) {
        this.editor.chain().focus(null, { scrollIntoView: false }).updateAttributes("image", { href: null, target: null }).run();
        return;
      }

      this.editor.chain().focus(null, { scrollIntoView: false }).unsetLink().run();
    } else {
      this.editor.commands.linkDialog();
    }
  }

  updateHref(href) {
    this.element.querySelector("[data-linkbubble-value]").textContent = href;
  }

  isImage(selection) {
    return selection instanceof NodeSelection && selection.node.type.name === "image";
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
