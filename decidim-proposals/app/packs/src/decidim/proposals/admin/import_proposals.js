import { Application } from "@hotwired/stimulus"
import ImportProposalsController from "src/decidim/proposals/admin/controllers/import_proposals/controller.js"

const application = Application.start()
application.register("import-proposals", ImportProposalsController)
