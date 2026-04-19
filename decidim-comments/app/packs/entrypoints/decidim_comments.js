// CSS
import "stylesheets/comments.scss"

// JavaScript
import "src/decidim/comments/comments"
import "src/decidim/comments/comments_mobile_modal"

// Stimulus controllers
import { definitionsFromContext } from "src/decidim/refactor/support/stimulus"

document.addEventListener("stimulus:load", () => {
  const context = require.context("src/decidim/comments/controllers", true, /controller\.js$/)
  window.Stimulus.load(definitionsFromContext(context))
}, { once: true })
