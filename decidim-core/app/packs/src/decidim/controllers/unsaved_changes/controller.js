import { Controller } from "@hotwired/stimulus"
import confirmAction from "src/decidim/confirm"
import { getMessages } from "src/decidim/refactor/moved/i18n"

const sameWindowTargets = ["_self", "_top", "_parent"]

export default class extends Controller {
  connect() {
    this.dirty = false;
    this.submitting = false;
    this.confirming = false;

    this.markDirty = () => {
      this.dirty = true;
      window.addEventListener("beforeunload", this.preventBeforeUnload);
    };

    this.markSubmitting = () => {
      this.submitting = true;
      window.removeEventListener("beforeunload", this.preventBeforeUnload);
      window.clearTimeout(this.submitTimer);
      this.submitTimer = window.setTimeout(() => {
        this.submitting = false;
        if (this.dirty) {
          window.addEventListener("beforeunload", this.preventBeforeUnload);
        }
      });
    };

    this.preventBeforeUnload = (event) => {
      if (!this.dirty || this.submitting) {
        return;
      }

      event.preventDefault();
      event.returnValue = true;
    };

    this.confirmNavigation = (event) => {
      const link = event.target?.closest("a[href]");

      if (!this.dirty || this.submitting || this.confirming || event.defaultPrevented || !link) {
        return;
      }

      const href = link.getAttribute("href");
      const target = link.getAttribute("target");
      const opensAnotherWindow = target && !sameWindowTargets.includes(target);
      const opensWithModifier = event.altKey || event.ctrlKey || event.metaKey || event.shiftKey;

      if (href.startsWith("#") || link.hasAttribute("download") || opensAnotherWindow || opensWithModifier) {
        return;
      }

      this.confirming = true;
      event.preventDefault();
      event.stopPropagation();

      const message = getMessages("confirmUnload") || "Are you sure you want to leave this page?";
      confirmAction(message, link, { iconName: "alert-line" }).then((confirmed) => {
        this.confirming = false;
        if (!confirmed) {
          return;
        }

        this.dirty = false;
        window.removeEventListener("beforeunload", this.preventBeforeUnload);
        link.click();
      });
    };

    this.element.addEventListener("input", this.markDirty);
    this.element.addEventListener("change", this.markDirty);
    this.element.addEventListener("submit", this.markSubmitting);
    document.addEventListener("click", this.confirmNavigation);
  }

  disconnect() {
    this.dirty = false;
    window.clearTimeout(this.submitTimer);
    window.removeEventListener("beforeunload", this.preventBeforeUnload);
    this.element.removeEventListener("input", this.markDirty);
    this.element.removeEventListener("change", this.markDirty);
    this.element.removeEventListener("submit", this.markSubmitting);
    document.removeEventListener("click", this.confirmNavigation);
  }
}
