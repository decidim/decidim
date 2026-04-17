// CSS
import "stylesheets/decidim/editor.scss"

import EditorController from "src/decidim/controllers/editor/controller";

window.addEventListener("DOMContentLoaded", () => {
  window.Stimulus.register("editor", EditorController);
})
