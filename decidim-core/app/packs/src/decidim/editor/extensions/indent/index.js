import { Extension } from "@tiptap/core";

// The node types for which indentation is allowed
const allowedNodeTypes = ["heading", "paragraph"];

/**
 * Helper method to check whether one of the allowed type nodes is currently
 * active where the indentation can be performed on.
 *
 * @param {Object} editor The editor instance.
 * @returns {Boolean} A boolean indicating if an allowed type node is active
 */
const allowedNodeActive = (editor) => allowedNodeTypes.some((type) => editor.isActive(type));

/**
 * Finds the closest allowed type node from the given position. Traversese the
 * document depth upwards to search through all the node parents.
 *
 * @param {Object} position The position where to look for
 * @returns {Node|null} The allowed node or null if no allowed node is found
 */
const closestAllowedNode = (position) => {
  let depth = position.depth;
  while (depth > 0) {
    const node = position.node(depth);
    if (allowedNodeTypes.some((type) => node.type.name === type)) {
      return node;
    }
    depth -= 1;
  }
  return null;
}

/**
 * Indent extension for the Tiptap editor.
 *
 * Originally based on the following MIT licensed code:
 * https://github.com/ueberdosis/tiptap/issues/1036#issuecomment-1000983233
 * https://github.com/evanfuture/tiptaptop-extension-indent
 *
 * License as specified at:
 * https://github.com/evanfuture/tiptaptop-extension-indent
 *
 * The code has been simplified and modified to fit better the needs of Decidim.
 *
 * Authors/Credits: Jeet Mandaliya (@sereneinserenade),
 *   Evan Payne (@evanfuture), @danline, YukiYama (@yuyuyukie)
 */
export default Extension.create({
  name: "indent",

  addOptions() {
    return {
      minIndentLevel: 0,
      maxIndentLevel: 10,
      HTMLAttributes: {}
    };
  },

  addGlobalAttributes() {
    const defaultIndentLevel = 0;

    return [
      {
        types: allowedNodeTypes,
        attributes: {
          indent: {
            default: defaultIndentLevel,
            renderHTML: (attributes) => {
              if (attributes.indent < 1) {
                return {};
              }

              return { class: `editor-indent-${attributes.indent}` };
            },
            parseHTML: (element) => {
              // The "ql" prefix here is to maintain backwards compatibility
              // with the old editor. The new prefix is editor-indent-X where X
              // is the current indentation level.
              const regexp = /^(editor|ql)-indent-([0-9]+)/;
              const indentClass = Array.from(element.classList).find((cls) => regexp.test(cls))
              if (!indentClass) {
                return defaultIndentLevel;
              }
              return parseInt(indentClass.match(regexp)[2], 10);
            }
          }
        }
      }
    ];
  },

  addCommands() {
    const updateIndent = (modifier, { editor, state, dispatch, commands }) => {
      if (!allowedNodeActive(editor)) {
        return false;
      }

      const node = closestAllowedNode(state.selection.$head);
      if (node === null) {
        return false;
      }

      const indent = node.attrs.indent + modifier;
      if (indent < this.options.minIndentLevel || indent > this.options.maxIndentLevel) {
        return false;
      }

      if (dispatch) {
        return commands.updateAttributes(node.type.name, { indent });
      }

      return true;
    }

    return {
      indent: () => ({ editor, state, commands, dispatch }) => {
        if (editor.isActive("listItem")) {
          if (dispatch) {
            return commands.sinkListItem("listItem");
          }
          return true;
        }

        return updateIndent(1, { editor, state, dispatch, commands})
      },
      outdent: () => ({ editor, state, commands, dispatch }) => {
        if (editor.isActive("listItem")) {
          // When the list item depth is at 3 it means that the list is at the
          // top level because of the following structure:
          // <ul><!-- depth: 1 -->
          //   <li><!-- depth: 2 -->
          //     <p>Content</p><!-- depth: 3 -->
          //   </li>
          // </ul>
          //
          // We do not allow outdent at the top level of the list.
          if (state.selection.$head.depth === 3) {
            return false;
          }
          if (dispatch) {
            return commands.liftListItem("listItem");
          }
          return true;
        }

        return updateIndent(-1, { editor, state, dispatch, commands})
      }
    }
  },

  addKeyboardShortcuts() {
    const indent = () => {
      if (!this.editor.can().indent()) {
        return false;
      }

      return this.editor.commands.indent();
    };
    const outdent = () => {
      if (!this.editor.can().outdent()) {
        return false;
      }

      return this.editor.commands.outdent();
    };

    return {
      Tab: indent,
      "Shift-Tab": outdent,
      Backspace: () => {
        if (this.editor.isActive("listItem")) {
          return false;
        }

        // With the backspace we only allow outdent when the cursor is at the
        // beginning of the line.
        if (this.editor.state.selection.$head.parentOffset > 0) {
          return false;
        }

        return outdent();
      },
      "Mod-]": indent,
      "Mod-[": outdent
    };
  }
});
