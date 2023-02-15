import OrderedList from "@tiptap/extension-ordered-list";

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

          return null;
        }
      }
    };
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
  }
});
