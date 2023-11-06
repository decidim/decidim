import { createEditorContainer } from "../helpers";
import itBehavesLikeContentToolbar from "./shared/behaves_like_content";

describe("content toolbar", () => {
  const ctx = {
    editorContainer: null
  };

  beforeEach(() => {
    document.body.innerHTML = "";
    ctx.editorContainer = createEditorContainer({ toolbar: "content" });
  });

  it("adds only the content editing controls", () => {
    const toolbar = ctx.editorContainer.querySelector(".editor-toolbar");

    expect(toolbar.querySelector("select[data-editor-type='heading'][title='Text style']")).toBeInstanceOf(HTMLElement);
    expect(toolbar.querySelector("button[data-editor-type='bold'][title='Bold']")).toBeInstanceOf(HTMLElement);
    expect(toolbar.querySelector("button[data-editor-type='italic'][title='Italic']")).toBeInstanceOf(HTMLElement);
    expect(toolbar.querySelector("button[data-editor-type='underline'][title='Underline']")).toBeInstanceOf(HTMLElement);
    expect(toolbar.querySelector("button[data-editor-type='hardBreak'][title='Line break']")).toBeInstanceOf(HTMLElement);
    expect(toolbar.querySelector("button[data-editor-type='orderedList'][title='Ordered list']")).toBeInstanceOf(HTMLElement);
    expect(toolbar.querySelector("button[data-editor-type='bulletList'][title='Unordered list']")).toBeInstanceOf(HTMLElement);
    expect(toolbar.querySelector("button[data-editor-type='link'][title='Link']")).toBeInstanceOf(HTMLElement);
    expect(toolbar.querySelector("button[data-editor-type='common:eraseStyles'][title='Erase styles']")).toBeInstanceOf(HTMLElement);
    expect(toolbar.querySelector("button[data-editor-type='codeBlock'][title='Code block']")).toBeInstanceOf(HTMLElement);
    expect(toolbar.querySelector("button[data-editor-type='blockquote'][title='Blockquote']")).toBeInstanceOf(HTMLElement);
    expect(toolbar.querySelector("button[data-editor-type='indent:indent'][title='Indent']")).toBeInstanceOf(HTMLElement);
    expect(toolbar.querySelector("button[data-editor-type='indent:outdent'][title='Outdent']")).toBeInstanceOf(HTMLElement);

    // These controls should not be added with the content editing controls
    expect(toolbar.querySelector("button[data-editor-type='videoEmbed'][title='Video embed']")).toBe(null);
    expect(toolbar.querySelector("button[data-editor-type='image'][title='Image']")).toBe(null);
  });

  itBehavesLikeContentToolbar(ctx);
});
