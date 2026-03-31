import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static get values() {
    return { currentPage: Number, perPage: Number }
  }

  connect() {
    this.element.querySelectorAll(".js-sortable").forEach((sortable) => {
      sortable.addEventListener("sortupdate", (event) => {
        this.handleSort(sortable, event);
      });
    });
  }

  handleSort(sortable, event) {
    sortable.classList.add("spinner-container");
    const itemsId = Array.from(event.target.children).map((item) => item.dataset.taxonomyId);
    const parentId = event.target.dataset.parentId ||
      (event.target.closest("[data-taxonomy-id]") && event.target.closest("[data-taxonomy-id]").dataset.taxonomyId) ||
      null;
    const token = document.querySelector("meta[name='csrf-token']");

    fetch(sortable.dataset.sortUrl, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": token && token.getAttribute("content")
      },
      body: JSON.stringify({
        page: this.currentPageValue,
        per_page: this.perPageValue, // eslint-disable-line camelcase
        ids_order: itemsId, // eslint-disable-line camelcase
        parent_id: parentId // eslint-disable-line camelcase
      })
    }).then((response) => {
      if (response.ok) {
        const nextPage = this.element.querySelector("[data-next-page]");
        const prevPage = this.element.querySelector("[data-prev-page]");
        const lastChild = this.element.querySelector(".draggable-taxonomy:last-child");
        const firstChild = this.element.querySelector(".draggable-taxonomy:first-child");

        if (lastChild && !lastChild.hasAttribute("data-next-page") && nextPage) {
          location.href = nextPage.dataset.nextPage;
        } else if (firstChild && !firstChild.hasAttribute("data-prev-page") && prevPage) {
          location.href = prevPage.dataset.prevPage;
        } else {
          sortable.classList.remove("spinner-container");
        }
      }
    });
  }
}
