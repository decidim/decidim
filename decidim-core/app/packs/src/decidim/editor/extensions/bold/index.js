import Bold from "@tiptap/extension-bold";

/**
 * Extends the bold extension to fix a bug with pasting the following kind of
 * content from Google docs (this is about how Google docs formats the content):
 *
 * <b style="font-weight:normal;">
 *   <ol>
 *      <li><p><span style="font-weight:700;">Item 1</span></p></li>
 *      <ol>
 *        <li><p><span style="font-weight:400;">Item 1</span></p></li>
 *      </ol>
 *   </ol>
 * </b>
 *
 * See: https://github.com/ueberdosis/tiptap/issues/3735
 */
export default Bold.extend({
  parseHTML() {
    return [
      {
        tag: "strong"
      },
      {
        tag: "b",
        getAttrs: (node) => node.style.fontWeight !== "normal" && node.style.fontWeight !== "400" && null
      },
      {
        tag: "span",
        getAttrs: (node) => (/^(bold(er)?|[5-9]\d{2,})$/).test(node.style.fontWeight) && null
      }
    ]
  }
});
