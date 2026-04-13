import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.draftButton = this.element.querySelector("button[name='save_draft']");
    this.list = this.element.querySelector("#participatory-text");

    if (this.draftButton) {
      this.boundDraftClick = this.handleDraftClick.bind(this);
      this.draftButton.addEventListener("click", this.boundDraftClick);
    }

    if (this.list) {
      this.boundSortUpdate = this.handleSortUpdate.bind(this);
      this.list.addEventListener("sortupdate", this.boundSortUpdate);
    }
  }

  disconnect() {
    if (this.draftButton && this.boundDraftClick) {
      this.draftButton.removeEventListener("click", this.boundDraftClick);
    }
    if (this.list && this.boundSortUpdate) {
      this.list.removeEventListener("sortupdate", this.boundSortUpdate);
    }
  }

  handleDraftClick(ev) {
    ev.preventDefault();
    const form = this.draftButton.closest("form");
    const hidden = document.createElement("input");
    hidden.type = "hidden";
    hidden.name = "save_draft";
    hidden.value = "true";
    form.appendChild(hidden);
    form.submit();
  }

  handleSortUpdate() {
    this.list.querySelectorAll("li").forEach((li, idx) => {
      const input = li.querySelector("input.position");
      if (input) {
        input.value = idx + 1;
      }
    });
  }
}
