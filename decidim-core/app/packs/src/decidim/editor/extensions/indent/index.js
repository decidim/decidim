/**
 * Indent extension for the Tiptap editor.
 *
 * Original sources from:
 * https://github.com/ueberdosis/tiptap/issues/1036#issuecomment-1000983233
 * https://github.com/evanfuture/tiptaptop-extension-indent
 *
 * License: MIT
 * License as specified at:
 * https://github.com/evanfuture/tiptaptop-extension-indent
 *
 * Authors/Credits: Jeet Mandaliya (@sereneinserenade),
 *   Evan Payne (@evanfuture), @danline, YukiYama (@yuyuyukie)
 */

import { Extension, isList } from "@tiptap/core";
import { TextSelection } from "prosemirror-state";

export const getIndent = () => ({ editor }) => {
  if (editor.can().sinkListItem("listItem")) {
    return editor.chain().focus().sinkListItem("listItem").run();
  }
  return editor.chain().focus().indent().run();
};

export const getOutdent = (outdentOnlyAtHead) => ({ editor }) => {
  if (outdentOnlyAtHead && editor.state.selection.$head.parentOffset > 0) {
    return false;
  }
  if (
    (!outdentOnlyAtHead || editor.state.selection.$head.parentOffset > 0) &&
    editor.can().liftListItem("listItem")
  ) {
    return editor.chain().focus().liftListItem("listItem").run();
  }
  return editor.chain().focus().outdent().run();
};

export const clamp = (val, min, max) => {
  if (val < min) {
    return min
  }
  if (val > max) {
    return max
  }
  return val
};

const setNodeIndentMarkup = ({ tr, pos, delta, min, max }) => {
  if (!tr.doc) {
    return tr;
  }
  const node = tr.doc.nodeAt(pos)
  if (!node) {
    return tr;
  }
  const indent = clamp((node.attrs.indent || 0) + delta, min, max);
  if (indent === node.attrs.indent) {
    return tr;
  }
  const nodeAttrs = {
    ...node.attrs,
    indent
  };
  return tr.setNodeMarkup(pos, node.type, nodeAttrs, node.marks);
};

const updateIndentLevel = ({ tr, options, extensions, type }) => {
  const { doc, selection } = tr;
  let finalTr = tr;
  if (!doc || !selection) {
    return finalTr;
  }
  if (!(selection instanceof TextSelection)) {
    return finalTr;
  }
  const { from, to } = selection;
  doc.nodesBetween(from, to, (node, pos) => {
    if (options.names.includes(node.type.name)) {
      let rangeFactor = -1;
      if (type === "indent") {
        rangeFactor = 1;
      }

      finalTr = setNodeIndentMarkup({
        tr: finalTr,
        pos,
        delta: options.indentRange * rangeFactor,
        min: options.minIndentLevel,
        max: options.maxIndentLevel
      });
      return false;
    }
    return !isList(node.type.name, extensions);
  })
  return finalTr;
};

export default Extension.create({
  name: "indent",

  addOptions() {
    return {
      names: ["heading", "paragraph"],
      indentRange: 1,
      minIndentLevel: 0,
      maxIndentLevel: 10,
      defaultIndentLevel: 0,
      HTMLAttributes: {}
    };
  },

  addGlobalAttributes() {
    return [
      {
        types: this.options.names,
        attributes: {
          indent: {
            default: this.options.defaultIndentLevel,
            renderHTML: (attributes) => {
              if (attributes.indent < 1) {
                return {};
              }

              return { class: `editor-indent-${attributes.indent}` };
            },
            parseHTML: (element) => {
              const regexp = /^editor-indent-([0-9]+)/;
              const indentClass = Array.from(element.classList).find((cls) => regexp.test(cls))
              if (!indentClass) {
                return this.options.defaultIndentLevel;
              }
              return parseInt(indentClass.match(regexp)[1], 10);
            }
          }
        }
      }
    ];
  },

  addCommands() {
    return {
      indent: () => ({ tr, state, dispatch, editor }) => {
        const { selection } = state;
        let finalTr = tr.setSelection(selection);
        finalTr = updateIndentLevel({
          tr: finalTr,
          options: this.options,
          extensions: editor.extensionManager.extensions,
          type: "indent"
        });
        if (finalTr.docChanged && dispatch) {
          dispatch(finalTr);
          return true;
        };
        return false;
      },
      outdent: () => ({ tr, state, dispatch, editor }) => {
        const { selection } = state;
        let finalTr = tr.setSelection(selection);
        finalTr = updateIndentLevel({
          tr: finalTr,
          options: this.options,
          extensions: editor.extensionManager.extensions,
          type: "outdent"
        });
        if (finalTr.docChanged && dispatch) {
          dispatch(finalTr);
          return true;
        }
        return false;
      }
    };
  },

  addKeyboardShortcuts() {
    return {
      Tab: getIndent(),
      "Shift-Tab": getOutdent(false),
      Backspace: getOutdent(true),
      "Mod-]": getIndent(),
      "Mod-[": getOutdent(false)
    };
  },

  onUpdate() {
    const { editor } = this
    if (editor.isActive("listItem")) {
      const node = editor.state.selection.$head.node();
      if (node.attrs.indent) {
        editor.commands.updateAttributes(node.type.name, { indent: 0 });
      }
    }
  }
});
