import "src/decidim/meetings/meetings_form"
import "src/decidim/meetings/meetings_polls"
import { definitionsFromContext } from "src/decidim/refactor/support/stimulus"

const context = require.context("./controllers", true, /controller\.js$/)
window.Stimulus.load(definitionsFromContext(context))
