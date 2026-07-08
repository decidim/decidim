import autofocus from "src/decidim/refactor/implementation/autofocus"

describe("autofocus", () => {
  describe("when ProseMirror editor is present", () => {
    it("dispatches move-cursor-to-end event on ProseMirror", () => {
      const container = document.createElement("div");
      const editor = document.createElement("div");
      editor.className = "editor";
      const prosemirror = document.createElement("div");
      prosemirror.className = "ProseMirror";
      editor.appendChild(prosemirror);
      container.appendChild(editor);
      document.body.appendChild(container);

      const dispatchSpy = jest.spyOn(prosemirror, "dispatchEvent");

      autofocus(container);

      expect(dispatchSpy).toHaveBeenCalledWith(expect.objectContaining({
        type: "move-cursor-to-end",
        bubbles: true
      }));
      dispatchSpy.mockRestore();
      container.remove();
    });

    it("calls focus on ProseMirror element", () => {
      const container = document.createElement("div");
      const editor = document.createElement("div");
      editor.className = "editor";
      const prosemirror = document.createElement("div");
      prosemirror.className = "ProseMirror";
      prosemirror.contentEditable = true;
      const focusSpy = jest.spyOn(prosemirror, "focus");
      editor.appendChild(prosemirror);
      container.appendChild(editor);
      document.body.appendChild(container);

      autofocus(container);

      expect(focusSpy).toHaveBeenCalled();
      focusSpy.mockRestore();
      container.remove();
    });
  });

  describe("when input[type='text'] is present", () => {
    it("focuses on the input element", () => {
      const container = document.createElement("div");
      const input = document.createElement("input");
      input.type = "text";
      input.value = "test value";
      const focusSpy = jest.spyOn(input, "focus");
      container.appendChild(input);
      document.body.appendChild(container);

      autofocus(container);

      expect(focusSpy).toHaveBeenCalled();
      expect(input.value).toBe("test value");
      focusSpy.mockRestore();
      container.remove();
    });

    it("clears and restores the input value", () => {
      const container = document.createElement("div");
      const input = document.createElement("input");
      input.type = "text";
      input.value = "original value";
      container.appendChild(input);
      document.body.appendChild(container);

      autofocus(container);

      expect(input.value).toBe("original value");
      container.remove();
    });
  });

  describe("when textarea is present", () => {
    it("focuses on the textarea element", () => {
      const container = document.createElement("div");
      const textarea = document.createElement("textarea");
      textarea.value = "textarea content";
      const focusSpy = jest.spyOn(textarea, "focus");
      container.appendChild(textarea);
      document.body.appendChild(container);

      autofocus(container);

      expect(focusSpy).toHaveBeenCalled();
      expect(textarea.value).toBe("textarea content");
      focusSpy.mockRestore();
      container.remove();
    });

    it("clears and restores the textarea value", () => {
      const container = document.createElement("div");
      const textarea = document.createElement("textarea");
      textarea.value = "original content";
      container.appendChild(textarea);
      document.body.appendChild(container);

      autofocus(container);

      expect(textarea.value).toBe("original content");
      container.remove();
    });
  });

  describe("when no focusable element is present", () => {
    it("does nothing and does not throw", () => {
      const container = document.createElement("div");
      container.innerHTML = "<p>No focusable element here</p>";
      document.body.appendChild(container);

      expect(() => autofocus(container)).not.toThrow();
      container.remove();
    });
  });

  describe("priority of elements", () => {
    it("prefers ProseMirror over input", () => {
      const container = document.createElement("div");
      const editor = document.createElement("div");
      editor.className = "editor";
      const prosemirror = document.createElement("div");
      prosemirror.className = "ProseMirror";
      editor.appendChild(prosemirror);
      const input = document.createElement("input");
      input.type = "text";
      editor.appendChild(input);
      container.appendChild(editor);
      document.body.appendChild(container);

      const prosemirrorDispatchSpy = jest.spyOn(prosemirror, "dispatchEvent");
      const inputFocusSpy = jest.spyOn(input, "focus");

      autofocus(container);

      expect(prosemirrorDispatchSpy).toHaveBeenCalled();
      expect(inputFocusSpy).not.toHaveBeenCalled();
      prosemirrorDispatchSpy.mockRestore();
      inputFocusSpy.mockRestore();
      container.remove();
    });

    it("prefers input over textarea", () => {
      const container = document.createElement("div");
      const input = document.createElement("input");
      input.type = "text";
      const textarea = document.createElement("textarea");
      container.appendChild(input);
      container.appendChild(textarea);
      document.body.appendChild(container);

      const inputFocusSpy = jest.spyOn(input, "focus");
      const textareaFocusSpy = jest.spyOn(textarea, "focus");

      autofocus(container);

      expect(inputFocusSpy).toHaveBeenCalled();
      expect(textareaFocusSpy).not.toHaveBeenCalled();
      inputFocusSpy.mockRestore();
      textareaFocusSpy.mockRestore();
      container.remove();
    });
  });
});
