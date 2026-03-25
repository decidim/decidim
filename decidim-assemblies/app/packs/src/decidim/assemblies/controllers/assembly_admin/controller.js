import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.assignBehavior("assembly_type");
    this.assignBehavior("created_by");
  }

  assignBehavior(field) {
    const assemblyCreatedBy = this.element.querySelector(`#assembly_${field}`);
    const assemblyCreatedByOther = this.element.querySelector(`#${field}_other`);
    this.attachVisibility(assemblyCreatedBy, assemblyCreatedByOther);
  }

  attachVisibility(type, other) {
    if (type && other) {
      type.addEventListener("change", (ev) => {
        this.toggleDependsOnSelect(ev.target, other);
      });
      this.toggleDependsOnSelect(type, other);
    }
  }

  toggleDependsOnSelect(target, showDiv) {
    if (!target || !showDiv) {
      return;
    }
    const value = target.value;

    showDiv.style.display = "none";
    if (value === "others") {
      showDiv.style.display = "block";
    }
  }
}
