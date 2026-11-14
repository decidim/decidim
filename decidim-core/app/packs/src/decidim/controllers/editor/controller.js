import { Controller } from "@hotwired/stimulus"
import createEditor from "src/decidim/editor";

export default class extends Controller {
  connect() {
    this.boundReveal = this.reveal.bind(this);
    this.element.addEventListener("editor:reveal", this.boundReveal);

    if (this.element.querySelector(".ProseMirror")) {
      if (this.reuseEditor()) {
        return;
      }

      this.element.dataset.editorInitialized = "true";
      this.toggleElements();
      return;
    }

    if (this.isDisabled()) {
      return;
    }

    if (typeof window.IntersectionObserver === "undefined") {
      this.initializeEditor();
      return;
    }

    this.observer = new IntersectionObserver((entries) => {
      if (entries.some((entry) => entry.isIntersecting)) {
        this.initializeEditor();
      }
    });

    this.observer.observe(this.element);
  }

  disconnect() {
    this.observer?.disconnect();
    this.element.removeEventListener("editor:reveal", this.boundReveal);
  }

  reveal() {
    return this.initializeEditor();
  }

  initializeEditor() {
    if (this.editor) {
      return this.editor;
    }

    // The editor may have been initialized before this controller connected
    // (for instance, when the element has been restored from a cache). Reuse
    // the existing instance instead of creating a duplicate.
    if (this.reuseEditor()) {
      return this.editor;
    }

    if (this.isDisabled()) {
      return null;
    }

    this.observer?.disconnect();
    this.toggleElements();
    this.editor = createEditor(this.element);
    this.element.dataset.editorInitialized = "true";
    this.dispatchInitialized();

    return this.editor;
  }

  reuseEditor() {
    const existingEditor = this.element.querySelector(".ProseMirror")?.editor;
    if (!existingEditor) {
      return false;
    }

    this.editor = existingEditor;
    this.element.dataset.editorInitialized = "true";
    this.toggleElements();
    this.dispatchInitialized();

    return true;
  }

  dispatchInitialized() {
    this.element.dispatchEvent(
      new CustomEvent("editor:initialized", { bubbles: true, detail: { editor: this.editor } })
    );
  }

  toggleElements() {
    this.element.querySelector(".editor-preview")?.setAttribute("hidden", "");
    this.element.querySelector(".editor-input")?.removeAttribute("hidden");
  }

  isDisabled() {
    const input = this.element.parentElement?.querySelector("input[type=hidden]");
    return this.element.dataset.disabled === "true" || Boolean(input?.disabled);
  }
}
