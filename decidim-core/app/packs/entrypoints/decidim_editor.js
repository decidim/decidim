// CSS
import "stylesheets/decidim/editor.scss"

import EditorController from "src/decidim/controllers/editor/controller";

window.addEventListener("turbo:load", () => {
  window.Stimulus.register("editor", EditorController);
})
