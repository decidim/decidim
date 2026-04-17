import { definitionsFromContext } from "src/decidim/refactor/support/stimulus"
document.addEventListener("turbo:load", () => {
  const context = require.context("../controllers", true, /controller\.js$/)
  window.Stimulus.load(definitionsFromContext(context))
});
