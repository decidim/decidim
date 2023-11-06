import { Plugin } from "prosemirror-state";

import CharacterCount from "@tiptap/extension-character-count";

/**
 * Extends the character counter to prevent adding new paragraphs after the
 * character limit is reached. The original character counter allows that.
 *
 * See: https://github.com/ueberdosis/tiptap/issues/3721
 */
export default CharacterCount.extend({
  addProseMirrorPlugins() {
    const limit = this.options.limit;
    const plugins = this.parent?.();
    if (limit === 0 || limit === null || !limit) {
      return plugins;
    }

    const  { storage } = this.editor;
    return [
      ...plugins,
      new Plugin({
        props: {
          handleKeyDown(view, event) {
            if (event.key === "Enter") {
              return storage.characterCount.characters() >= limit;
            }

            return false;
          }
        }
      })
    ];
  }
});
