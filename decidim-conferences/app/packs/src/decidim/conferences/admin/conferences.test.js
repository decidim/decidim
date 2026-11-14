/* global jest */

import "src/decidim/conferences/admin/conferences";

describe("conference registrations", () => {
  const editorMarkup = (id) => `
    <div class="editor">
      <input type="hidden" name="conference[registration_terms_en]">
      <div class="editor-container" id="${id}" data-controller="editor">
        <div class="editor-preview"></div>
        <div class="editor-input" hidden></div>
      </div>
    </div>
  `;

  const initializeEditor = (container, editor) => {
    const proseMirror = document.createElement("div");
    proseMirror.classList.add("ProseMirror");
    proseMirror.editor = editor;
    container.querySelector(".editor-input").appendChild(proseMirror);
    container.dispatchEvent(new CustomEvent("editor:initialized", {
      bubbles: true,
      detail: { editor }
    }));
  };

  beforeEach(() => {
    document.body.innerHTML = `
      <form class="edit_conference">
        <input type="checkbox" id="conference_registrations_enabled" checked>
        <input type="number" id="conference_available_slots">
        <div id="conference_registrations_terms">
          ${editorMarkup("registration-terms-editor")}
        </div>
      </form>
    `;

    document.dispatchEvent(new Event("turbo:load"));
  });

  afterEach(() => {
    document.body.innerHTML = "";
  });

  it("applies the current state to editors initialized after the toggle ran", () => {
    const checkbox = document.querySelector("#conference_registrations_enabled");
    checkbox.checked = false;
    checkbox.dispatchEvent(new Event("change"));

    const editor = { setOptions: jest.fn() };
    initializeEditor(document.querySelector("#registration-terms-editor"), editor);

    expect(editor.setOptions).toHaveBeenCalledWith({ editable: false });
  });

  it("applies the enabled state to editors initialized after the toggle ran", () => {
    const checkbox = document.querySelector("#conference_registrations_enabled");
    checkbox.checked = true;
    checkbox.dispatchEvent(new Event("change"));

    const editor = { setOptions: jest.fn() };
    initializeEditor(document.querySelector("#registration-terms-editor"), editor);

    expect(editor.setOptions).toHaveBeenCalledWith({ editable: true });
  });

  it("keeps applying the state to editors when the toggle changes", () => {
    const checkbox = document.querySelector("#conference_registrations_enabled");
    const editor = { setOptions: jest.fn() };
    initializeEditor(document.querySelector("#registration-terms-editor"), editor);

    checkbox.checked = false;
    checkbox.dispatchEvent(new Event("change"));
    expect(editor.setOptions).toHaveBeenLastCalledWith({ editable: false });

    checkbox.checked = true;
    checkbox.dispatchEvent(new Event("change"));
    expect(editor.setOptions).toHaveBeenLastCalledWith({ editable: true });
  });
});
