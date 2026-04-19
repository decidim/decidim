// CSS
import "stylesheets/decidim/editor.scss"

import EditorController from "src/decidim/controllers/editor/controller";

document.addEventListener("stimulus:load", () => {
  window.Stimulus.register("editor", EditorController);
}, { once: true });
