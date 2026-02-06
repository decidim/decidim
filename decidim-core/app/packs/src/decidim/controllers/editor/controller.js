import { Controller } from "@hotwired/stimulus"
import createEditor from "src/decidim/editor";

export default class extends Controller {
  connect() {
    if (!this.element.dataset.editorInitialized) {
      this.editor = createEditor(this.element);
      this.element.dataset.editorInitialized = true;
    }
  }
}
