import { Plugin } from "prosemirror-state";

import CharacterCount from "@tiptap/extension-character-count";

/**
 * Extends the character counter to prevent adding new paragraphs after the
 * character limit is reached. The original character counter allows that.
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
            const currentCount = storage.characterCount.characters();
            if (event.key === "Enter") {
              return currentCount >= limit;
            }

            return false;
          }
        }
      })
    ];
  }
});
