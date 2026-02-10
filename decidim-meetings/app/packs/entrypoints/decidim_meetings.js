import "src/decidim/meetings/meetings_form"
import "src/decidim/meetings/meetings_polls"
import "src/decidim/forms/forms"
import { definitionsFromContext } from "src/decidim/refactor/support/stimulus"

const context = require.context("../src/decidim/meetings/controllers", true, /controller\.js$/)
window.Stimulus.load(definitionsFromContext(context))

// Images
require.context("../images", true)

// CSS
import "stylesheets/decidim/meetings/meetings.scss"
