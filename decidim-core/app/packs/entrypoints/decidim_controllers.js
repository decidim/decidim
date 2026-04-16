import { Application } from "@hotwired/stimulus"
import { definitionsFromContext } from "src/decidim/refactor/support/stimulus"

const application = Application.start()
application.debug = true

const context = require.context("src/decidim/controllers", true, /controller\.js$/)
application.load(definitionsFromContext(context))

window.definitionsFromContext = definitionsFromContext
window.Stimulus = application
