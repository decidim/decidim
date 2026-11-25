/* global jest */

import "src/decidim/meetings/admin/registrations_form";

describe("meeting registrations form", () => {
  const editorMarkup = (id) => `
    <div class="editor">
      <input type="hidden" name="meeting[registration_terms_en]">
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
      <form class="edit_meeting_registrations">
        <input type="checkbox" id="meeting_registrations_enabled" checked>
        <input type="number" id="meeting_available_slots">
        <input type="number" id="meeting_reserved_slots">
        <input type="checkbox" id="meeting_customize_registration_email">
        <div class="editor">
          <input type="hidden" name="meeting[registration_terms_en]">
          <div class="editor-container" id="registration-terms-editor" data-controller="editor">
            <div class="editor-preview"></div>
            <div class="editor-input" hidden></div>
          </div>
        </div>
        ${editorMarkup("registration-email-editor")}
      </form>
    `;

    document.dispatchEvent(new Event("turbo:load"));
  });

  afterEach(() => {
    document.body.innerHTML = "";
  });

  it("applies the current state to editors initialized after the toggle ran", () => {
    const checkbox = document.querySelector("#meeting_registrations_enabled");
    checkbox.checked = false;
    checkbox.dispatchEvent(new Event("change"));

    const editor = { setOptions: jest.fn() };
    initializeEditor(document.querySelector("#registration-terms-editor"), editor);

    expect(editor.setOptions).toHaveBeenCalledWith({ editable: false });
  });

  it("applies the current state to each editor as it initializes", () => {
    const checkbox = document.querySelector("#meeting_registrations_enabled");
    checkbox.checked = false;
    checkbox.dispatchEvent(new Event("change"));

    const termsEditor = { setOptions: jest.fn() };
    const emailEditor = { setOptions: jest.fn() };
    initializeEditor(document.querySelector("#registration-terms-editor"), termsEditor);
    initializeEditor(document.querySelector("#registration-email-editor"), emailEditor);

    expect(termsEditor.setOptions).toHaveBeenCalledWith({ editable: false });
    expect(emailEditor.setOptions).toHaveBeenCalledWith({ editable: false });
  });

  it("keeps applying the state to editors when the toggle changes", () => {
    const checkbox = document.querySelector("#meeting_registrations_enabled");
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
