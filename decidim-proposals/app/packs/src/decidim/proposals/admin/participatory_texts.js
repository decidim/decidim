import { Application } from "@hotwired/stimulus"
import ParticipatoryTextsController from "src/decidim/proposals/admin/controllers/participatory_texts/controller.js"

const application = Application.start()
application.register("participatory-texts", ParticipatoryTextsController)
