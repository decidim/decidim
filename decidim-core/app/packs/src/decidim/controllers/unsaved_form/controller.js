/**
 * Should the user navigate away from the page with unsaved changes in the form,
 * this controller will prompt the user for unsaved changes confirmation before closing.
 * Changes that do not fire `input` or `change` events, such as adding, removing
 * or reordering questions, are tracked as well, and remote forms are only saved on success.
 **/

import { Controller } from "@hotwired/stimulus"
import confirmAction from "src/decidim/confirm"
import { getMessages } from "src/decidim/refactor/moved/i18n"

const sameWindowTargets = ["_self", "_top", "_parent"]

const structureControls = [
  ".add-question",
  ".add-separator",
  ".add-title-and-description",
  ".remove-question",
  ".move-up-question",
  ".move-down-question",
  ".add-response-option",
  ".remove-response-option",
  ".add-matrix-row",
  ".remove-matrix-row",
  ".add-display-condition",
  ".remove-display-condition"
].join(", ")

export default class extends Controller {
  connect() {
    this.dirty = false;
    this.confirming = false;
    const remote = this.element.getAttribute("data-remote");
    this.remote = remote !== null && remote !== "false";

    this.markDirty = () => {
      this.dirty = true;
      window.addEventListener("beforeunload", this.preventBeforeUnload);
    };

    this.markSaved = () => {
      this.dirty = false;
      window.removeEventListener("beforeunload", this.preventBeforeUnload);
    };

    this.markStructureChanged = (event) => {
      if (event.target?.closest?.(structureControls)) {
        this.markDirty();
      }
    };

    this.markSubmitting = (event) => {
      if (event.defaultPrevented) {
        return;
      }

      if (this.remote) {
        return;
      }

      queueMicrotask(() => {
        if (event.defaultPrevented) {
          return;
        }
        this.markSaved();
      });
    };

    this.markSavedOnSuccess = (event) => {
      const [xhr] = event.detail || [];

      // A failed request leaves the form, and its unsaved contents, in place.
      if (!xhr || !(xhr.status >= 200 && xhr.status < 300)) {
        return;
      }

      this.markSaved();
    };

    this.preventBeforeUnload = (event) => {
      if (!this.dirty) {
        return;
      }

      event.preventDefault();
      event.returnValue = true;
    };

    this.confirmNavigation = (event) => {
      const link = event.target?.closest("a[href]");

      if (!this.dirty || event.defaultPrevented || !link) {
        return;
      }

      const href = link.getAttribute("href");
      const target = link.getAttribute("target");
      const opensAnotherWindow = target && !sameWindowTargets.includes(target);
      const opensWithModifier = event.altKey || event.ctrlKey || event.metaKey || event.shiftKey;

      if (href.startsWith("#") || link.hasAttribute("download") || link.hasAttribute("data-unsaved-form-ignore") || opensAnotherWindow || opensWithModifier) {
        return;
      }

      if (this.confirming) {
        event.preventDefault();
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

        this.markSaved();
        link.click();
      });
    };

    this.element.addEventListener("input", this.markDirty);
    this.element.addEventListener("change", this.markDirty);
    this.element.addEventListener("sortupdate", this.markDirty, true);
    this.element.addEventListener("submit", this.markSubmitting);
    this.element.addEventListener("ajax:complete", this.markSavedOnSuccess);
    document.addEventListener("click", this.confirmNavigation);
    document.addEventListener("click", this.markStructureChanged, true);
  }

  disconnect() {
    this.dirty = false;
    window.removeEventListener("beforeunload", this.preventBeforeUnload);
    this.element.removeEventListener("input", this.markDirty);
    this.element.removeEventListener("change", this.markDirty);
    this.element.removeEventListener("sortupdate", this.markDirty, true);
    this.element.removeEventListener("submit", this.markSubmitting);
    this.element.removeEventListener("ajax:complete", this.markSavedOnSuccess);
    document.removeEventListener("click", this.confirmNavigation);
    document.removeEventListener("click", this.markStructureChanged, true);
  }
}
