import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const privateSpace = this.element.querySelector("#private_space");

    if (privateSpace) {
      privateSpace.addEventListener("change", this.toggleDisabledHiddenFields);
    }
    this.toggleDisabledHiddenFields();

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

  toggleDisabledHiddenFields() {
    const privateSpace = document.getElementById("private_space");
    const isTransparent = document.getElementById("is_transparent");
    const specialFeatures = document.getElementById("special_features");

    const enabledPrivateSpace = privateSpace?.querySelector("input[type='checkbox']")?.checked;
    const isTransparentCheckbox = isTransparent?.querySelector("input[type='checkbox']");

    if (isTransparentCheckbox) {
      isTransparentCheckbox.disabled = (enabledPrivateSpace === false);
    }

    if (specialFeatures) {
      specialFeatures.style.display = enabledPrivateSpace
        ? "block"
        : "none";
    }
  }

}
