import { Controller } from "@hotwired/stimulus"
import formDatePicker from "src/decidim/datepicker/form_datepicker"

export default class extends Controller {
  connect() {
    this.datepicker = formDatePicker(this.element)
  }

  disconnect() {
    this.datepicker = null;
  }
}
