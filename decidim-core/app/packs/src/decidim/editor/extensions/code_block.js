import { mergeAttributes } from "@tiptap/core";
import CodeBlock from "@tiptap/extension-code-block";

export default CodeBlock.extend({
  renderHTML({ node, HTMLAttributes }) {
    let cls = ["code-block"];
    if (node.attrs.language) {
      cls.push(this.options.languageClassPrefix + node.attrs.language);
    }

    return [
      "pre",
      mergeAttributes(this.options.HTMLAttributes, HTMLAttributes),
      [
        "code",
        { class: cls.join(" ") },
        0
      ]
    ];
  }
});
