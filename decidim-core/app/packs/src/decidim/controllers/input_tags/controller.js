/* eslint-disable camelcase */

import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select/dist/cjs/tom-select.popular";

export default class extends Controller {
  initialize() {
    this.config = {
      plugins: ["remove_button"],
      create: true,
      render: {
        no_results: null
      }
    };
  }

  connect() {
    this.tomSelect = new TomSelect(this.element, this.config)
  }

  disconnect() {
    if (!this.tomSelect) {
      return;
    }

    this.tomSelect.destroy();
  }
}
