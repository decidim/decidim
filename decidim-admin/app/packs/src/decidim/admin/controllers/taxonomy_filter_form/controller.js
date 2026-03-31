import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static get targets() {
    return ["selectAll", "counter"]
  }

  static get values() {
    return { autoSelect: Boolean }
  }

  connect() {
    if (this.autoSelectValue && this.hasSelectAllTarget) {
      this.selectAllTarget.checked = true;
      this.selectAllTarget.dispatchEvent(new Event("change"));
    }
    this.syncSelectAll();
    this.updateCounter();
  }

  toggleAll() {
    const checked = this.selectAllTarget.checked;
    this.checkboxes.forEach((checkbox) => {
      checkbox.checked = checked;
    });
    this.updateCounter();
  }

  toggleItem(event) {
    this.toggleChildrenSelect(event.target);
    this.syncSelectAll();
    this.updateCounter();
  }

  syncSelectAll() {
    if (!this.hasSelectAllTarget) {
      return;
    }
    const allChecked = Array.from(this.checkboxes).every((cb) => cb.checked);
    this.selectAllTarget.checked = allChecked;
  }

  toggleChildrenSelect(checkbox) {
    const children = this.element.querySelectorAll(
      `.js-taxonomy-children[data-parent='${checkbox.value}'] [type='checkbox'][name='taxonomy_filter[taxonomy_items][]']`
    );
    children.forEach((child) => {
      child.checked = checkbox.checked;
      this.toggleChildrenSelect(child);
    });
  }

  updateCounter() {
    if (!this.hasCounterTarget) {
      return;
    }
    const checked = Array.from(this.checkboxes).filter((cb) => cb.checked);
    this.counterTarget.innerHTML = checked.length;
  }

  get checkboxes() {
    return this.element.querySelectorAll(
      "[type='checkbox'][name='taxonomy_filter[taxonomy_items][]']"
    );
  }
}
