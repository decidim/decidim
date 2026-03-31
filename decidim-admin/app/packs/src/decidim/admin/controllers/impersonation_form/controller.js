import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    if (window.Decidim && window.Decidim.managedUsersForm) {
      window.Decidim.managedUsersForm();
    }
  }
}
