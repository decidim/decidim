import { mergeAttributes } from "@tiptap/core";
import OrderedList from "@tiptap/extension-ordered-list";
import { Plugin } from "prosemirror-state";

import transformPastedHTML from "src/decidim/editor/utilities/paste_transform";

const allowedListTypes = ["a", "A", "i", "I"];

const covertListStyleToType = (style) => {
  switch (style) {
  case "lower-alpha":
  case "lower-latin":
    return "a";
  case "upper-alpha":
  case "upper-latin":
    return "A";
  case "lower-roman":
    return "i";
  case "upper-roman":
    return "I";
  default:
    return "1";
  }
};

/**
 * This extension is customized in order to support the different styles of
 * ordered lists, such as the following.
 *
 * type "a":
 *   a) List item 1
 *   b) List item 2
 *   c) List item 3
 *
 * type "A":
 *   A) List item 1
 *   B) List item 2
 *   C) List item 3
 *
 * type "i":
 *   i) List item 1
 *   ii) List item 2
 *   iii) List item 3
 *
 * type "I":
 *   I) List item 1
 *   II) List item 2
 *   III) List item 3
 *
 * See: https://github.com/ueberdosis/tiptap/issues/3726
 */
export default OrderedList.extend({
  addAttributes() {
    return {
      ...this.parent?.(),
      type: {
        default: null,
        parseHTML: (element) => {
          let type = element.getAttribute("type");
          if (allowedListTypes.includes(type)) {
            return type;
          }

          // Google Docs
          const listItem = element.querySelector("li");
          if (listItem) {
            type = covertListStyleToType(listItem.style.listStyleType);
            if (allowedListTypes.includes(type)) {
              return type;
            }
          }

          // Office 365
          type = covertListStyleToType(element.style.listStyleType);
          if (allowedListTypes.includes(type)) {
            return type;
          }

          return null;
        }
      }
    };
  },

  /**
   * Overridden render method to add the `data-type` attribute for the typed
   * ordered lists as a workaround to style these lists properly. The following
   * issue with the CSS attribute selectors for the `type` attribute prevents
   * styling them properly otherwise: https://stackoverflow.com/q/53099708.
   *
   * The issue cannot be solved without this until the case sensitivity selector
   * is implemented by browsers and widely available:
   * https://caniuse.com/mdn-css_selectors_attribute_case_sensitive_modifier
   *
   * This has been already agreed by the CSS working group as per:
   * https://github.com/w3c/csswg-drafts/commit/de57526
   *
   * For further details, see:
   * https://github.com/tailwindlabs/tailwindcss-typography/issues/296
   *
   * @param {Object} attributes The attributes object containing the
   *   `HTMLAttributes` key for the attributes to be rendered
   * @returns {Array} The node definition array as defined by TipTap
   */
  renderHTML({ HTMLAttributes }) {
    const { start, ...attributesWithoutStart } = HTMLAttributes

    let attrs = null;
    if (start === 1) {
      attrs = mergeAttributes(this.options.HTMLAttributes, attributesWithoutStart);
    } else {
      attrs = mergeAttributes(this.options.HTMLAttributes, HTMLAttributes);
    }

    if (attrs.type) {
      attrs["data-type"] ??= attrs.type;
    }

    return ["ol", attrs, 0]
  },

  addCommands() {
    return {
      ...this.parent?.(),
      setOrderedListType: (type) => ({ commands, dispatch }) => {
        const listActive = this.editor.isActive("orderedList");
        if (dispatch && listActive) {
          return commands.updateAttributes("orderedList", { type });
        }
        return listActive;
      }
    };
  },

  addKeyboardShortcuts() {
    const currentType = () => {
      return this.editor.getAttributes("orderedList").type;
    };
    const determineType = (type, direction) => {
      let idx = allowedListTypes.indexOf(type) + direction;
      if (idx === -2) {
        idx = allowedListTypes.length - 1;
      } else if (idx < 0 || idx >= allowedListTypes.length) {
        return null;
      }
      return allowedListTypes[idx];
    };
    const listTypeChange = (direction) => {
      if (!this.editor.isActive("orderedList")) {
        return false;
      }

      const type = determineType(currentType(), direction);
      if (!this.editor.can().setOrderedListType(type)) {
        return false;
      }

      return this.editor.commands.setOrderedListType(type);
    }

    return {
      ...this.parent?.(),
      "Alt-Shift-ArrowUp": () => listTypeChange(-1),
      "Alt-Shift-ArrowDown": () => listTypeChange(1)
    }
  },

  /**
   * Adds a plugin that modifies the pasted HTML before it is passed to the
   * editor to fix some problems in the pasted content structure from different
   * online and desktop editors.
   *
   * See: https://github.com/ueberdosis/tiptap/issues/3751
   *
   * @returns {Array} The ProseMirror plugins provided by this extension
   */
  addProseMirrorPlugins() {
    return [
      new Plugin({
        props: {
          transformPastedHTML(html) {
            return transformPastedHTML(html);
          }
        }
      })
    ];
  }
});
