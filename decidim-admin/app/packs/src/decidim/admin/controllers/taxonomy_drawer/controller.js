import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static get values() {
    return { drawerId: String }
  }

  open(event) {
    event.preventDefault();

    if (!this.drawer) {
      this.drawer = window.Decidim.currentDialogs[this.drawerIdValue];
      this.container = this.drawer.dialog.querySelector("[data-dialog-container]");
    }

    this.container.innerHTML = '<div class="spinner-container">&nbsp;</div>';
    fetch(event.currentTarget.getAttribute("href")).
      then((response) => response.text()).
      then((html) => this.setDrawerContent(html));
    this.drawer.open();
  }

  setDrawerContent(content) {
    this.container.innerHTML = content;

    const form = this.container.querySelector("#taxonomy-item-form");
    if (!form) {
      location.reload();
      return;
    }
    window.initFoundation(this.container);

    form.addEventListener("ajax:beforeSend", () => {
      form.classList.add("spinner-container");
    });

    form.addEventListener("ajax:success", (evt) => {
      const [data, , xhr] = evt.detail;
      if (xhr.responseURL.indexOf(location.pathname) > -1) {
        location.href = xhr.responseURL;
      } else {
        this.setDrawerContent(data.body.innerHTML);
      }
    });

    form.addEventListener("ajax:error", (evt) => {
      const [data, , xhr] = evt.detail;
      if (xhr.responseURL.indexOf(location.pathname) > -1) {
        location.href = xhr.responseURL;
      } else {
        this.setDrawerContent(data.body.innerHTML);
      }
    });
  }
}
