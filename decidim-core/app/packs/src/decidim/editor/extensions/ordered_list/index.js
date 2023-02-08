import OrderedList from "@tiptap/extension-ordered-list";

const allowedListTypes = ["a", "A", "i", "I"];

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
          const type = element.getAttribute("type");
          if (allowedListTypes.includes(type)) {
            return type;
          }
          return null;
        }
      }
    };
  }
});
