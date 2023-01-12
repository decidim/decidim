import { createBasicEditor } from "../helpers";

import CodeBlock from "../../extensions/code_block";

describe("CodeBlock", () => {
  beforeEach(() => (document.body.innerHTML = ""));

  it("rendes correctly", () => {
    const editor = createBasicEditor({ extensions: [CodeBlock] })

    editor.commands.insertContent({
      type: "codeBlock",
      content: [{ type: "text", text: "Hello, world!" }]
    });

    expect(editor.getHTML()).toEqual('<pre><code class="code-block">Hello, world!</code></pre>');
  });
});
