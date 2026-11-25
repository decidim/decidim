import { Controller } from "@hotwired/stimulus"
import createEditor from "src/decidim/editor";

export default class extends Controller {
  connect() {
    this.boundReveal = this.reveal.bind(this);
    this.boundPreviewFocus = this.onPreviewFocus.bind(this);
    this.element.addEventListener("editor:reveal", this.boundReveal);

    if (this.element.querySelector(".ProseMirror")) {
      if (this.reuseEditor()) {
        return;
      }

      // The container may have been restored or cloned with the editor markup
      // but without a live editor instance. Discard the stale node and
      // continue with the regular lazy initialization.
      this.removeStaleEditor();
    }

    if (this.isDisabled()) {
      return;
    }

    // The preview is focusable so keyboard users can reach editors that are
    // outside the viewport and therefore not initialized by the intersection
    // observer yet.
    this.preview = this.element.querySelector(".editor-preview");
    this.preview?.addEventListener("focus", this.boundPreviewFocus);

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
    this.preview?.removeEventListener("focus", this.boundPreviewFocus);
  }

  reveal() {
    return this.initializeEditor();
  }

  onPreviewFocus() {
    if (!this.initializeEditor()) {
      return;
    }

    this.focusEditor();
  }

  focusEditor() {
    this.element.querySelector(".editor-input .ProseMirror")?.focus();
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

    this.removeStaleEditor();

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

  removeStaleEditor() {
    const staleNodes = this.element.querySelectorAll(".ProseMirror");
    if (staleNodes.length === 0) {
      return;
    }

    staleNodes.forEach((node) => node.remove());

    // Without a live editor instance this marker would prevent the lazy reveal
    // path in `autofocus.js` from initializing the container again.
    delete this.element.dataset.editorInitialized;

    // Show the lightweight preview again until the editor is initialized.
    this.showPreview();
  }

  showPreview() {
    this.element.querySelector(".editor-preview")?.removeAttribute("hidden");
    this.element.querySelector(".editor-input")?.setAttribute("hidden", "");
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
