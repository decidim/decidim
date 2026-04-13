import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  prevent(event) {
    event.preventDefault();
  }
}
