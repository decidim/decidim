/* global global, jest */

import "src/decidim/templates/admin/proposal_answer_template_chooser";

describe("proposal answer template chooser", () => {
  const templateContent = "<p>Template content</p>";
  const originalFetch = global.fetch;

  let editorContainer = null;
  let setContent = null;
  let revealEditor = null;

  const flushPromises = () => new Promise((resolve) => setTimeout(resolve, 0));

  const selectTemplate = () => {
    const dropdown = document.getElementById("proposal_answer_template_chooser");
    dropdown.value = "2";
    dropdown.dispatchEvent(new Event("change"));
  };

  beforeEach(() => {
    document.body.innerHTML = `
      <select id="proposal_answer_template_chooser" data-url="https://decidim.dev/admin/proposal_answer_templates/fetch" data-proposal="1">
        <option value="">Select a template</option>
        <option value="2">Template</option>
      </select>
      <input type="radio" id="proposal_answer_internal_state_rejected">
      <div class="editor" id="proposal_answer_answer_en">
        <input type="hidden" name="proposal_answer[answer_en]" value="">
        <div class="editor-container" data-controller="editor">
          <div class="editor-preview"><p>Preview</p></div>
          <div class="editor-input" hidden></div>
        </div>
      </div>
    `;

    editorContainer = document.querySelector(".editor-container");
    setContent = jest.fn();
    revealEditor = jest.fn(() => {
      const proseMirror = document.createElement("div");
      proseMirror.classList.add("ProseMirror");
      proseMirror.editor = { commands: { setContent } };
      editorContainer.querySelector(".editor-input").appendChild(proseMirror);
    });
    editorContainer.addEventListener("editor:reveal", revealEditor);

    global.fetch = jest.fn(() => Promise.resolve({
      ok: true,
      json: () => Promise.resolve({
        state: "rejected",
        template: { en: templateContent }
      })
    }));

    document.dispatchEvent(new Event("turbo:load"));
  });

  afterEach(() => {
    document.body.innerHTML = "";
    global.fetch = originalFetch;
  });

  it("reveals the target editor before inserting the template", async () => {
    selectTemplate();
    await flushPromises();

    expect(revealEditor).toHaveBeenCalledTimes(1);
    expect(setContent).toHaveBeenCalledWith(templateContent, true);
  });

  it("waits for the editor initialization when it is not ready synchronously", async () => {
    editorContainer.removeEventListener("editor:reveal", revealEditor);

    selectTemplate();
    await flushPromises();

    expect(setContent).not.toHaveBeenCalled();

    editorContainer.dispatchEvent(new CustomEvent("editor:initialized", {
      bubbles: true,
      detail: { editor: { commands: { setContent } } }
    }));

    expect(setContent).toHaveBeenCalledWith(templateContent, true);
  });
});
