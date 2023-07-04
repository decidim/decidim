import { textblockTypeInputRule } from "@tiptap/core";

import Heading from "@tiptap/extension-heading";

/**
 * Customized version of the Heading extension in order to fix compatibility
 * issue with the Hashtag extension. The default input rule of the Heading
 * extension would also match any paragraphs that have only one hashtag in them
 * and nothing else because that indicates the first level of heading.
 *
 * E.g.
 * - If you have the following paragraph: `<p>#apples</p>`
 * - This would be converted to a paragraph containing the hashtag node markup
 *   in the editor.
 * - If you come back to edit this content and try to enter a space right after
 *   the hashtag, the hashtag would disappear and the active text block would
 *   get the second heading level applied to it
 *
 * Since we do not allow the user to enter the first level of headings through
 * the editor, we can fix this by limiting the markdown shortcut to the second
 * level headings and above.
 */
export default Heading.extend({
  addInputRules() {
    return this.options.levels.map((level) => {
      return textblockTypeInputRule({
        find: new RegExp(`^(#{2,${level}})\\s$`),
        type: this.type,
        getAttributes: { level }
      })
    })
  }
});
