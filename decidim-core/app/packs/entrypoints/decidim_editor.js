// CSS
import "stylesheets/decidim/editor.scss"

import EditorController from "src/decidim/controllers/editor/controller";

document.addEventListener("stimulus:load", () => {
  console.log("Editor controller registered");
  window.Stimulus.register("editor", EditorController);
})
