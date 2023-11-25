import icon from "src/decidim/icon";
import { fileNameToTitle } from "src/decidim/editor/utilities/file";

const createElement = (template) => {
  const el = document.createElement("div");
  el.innerHTML = template;
  return el.firstElementChild;
}

/**
 * This is a simplified version of the normal upload dialog, uses the same
 * markup as the normal upload dialog to maintain consistency.
 *
 * The functionality differs from the original dialog as this only handles the
 * file uploads for the editor and the purpose is to simply provide the same
 * upload functionality and ability to update the alternative texts for the
 * images within the editor.
 *
 * This works only for the editor and does not store the files in the view
 * inputs as they are only used.
 */
export default class UploadDialog {
  constructor(element, { i18n, onOpen, onClose }) {
    this.element = element;
    this.i18n = i18n;
    this.onOpen = onOpen;
    this.onClose = onClose;

    this.values = { src: null, alt: null };
    this.dropZoneEnabled = true;
    this.exitMode = "cancel";

    let extra = null;
    this.messageSection = document.createElement("div");
    this.currentFileSection = document.createElement("div");
    this.inputSection = document.createElement("div");
    this.saveButton = this.element.querySelector("button[data-dropzone-save]");
    this.cancelButton = this.element.querySelector("button[data-dropzone-cancel]");
    this.dropZone = this.element.querySelector("[data-dropzone]");

    extra = document.createElement("div");
    this.dropZone.parentNode.insertBefore(extra, this.dropZone.nextSibling);

    extra.append(this.messageSection);
    extra.append(this.currentFileSection);

    this.dropZone.parentNode.querySelector(".upload-modal__text").classList.add("mb-0");
    this.dropZone.parentNode.append(this.inputSection);

    this.saveButton.addEventListener("click", () => {
      this.exitMode = "save";
    });
    this.cancelButton.addEventListener("click", () => {
      this.exitMode = "cancel";
    });

    this.dropZone.addEventListener("change", (event) => {
      event.preventDefault();
      const files = event.target.files;
      if (files.length < 1) {
        return;
      }
      this.uploadFile(files[0]);
    });

    const toggleDragover = (active) => {
      if (active) {
        this.dropZone.classList.add("is-dragover");
        this.dropZone.querySelectorAll(".upload-modal__dropzone").forEach((el) => el.classList.add("is-dragover"));
      } else {
        this.dropZone.classList.remove("is-dragover");
        this.dropZone.querySelectorAll(".upload-modal__dropzone").forEach((el) => el.classList.remove("is-dragover"));
      }
    };
    const dropEvents = {
      dragenter: (event) => event.preventDefault(),
      dragleave: () => toggleDragover(false),
      dragover: (event) => {
        event.preventDefault();
        toggleDragover(true);
      },
      drop: (event) => {
        event.preventDefault();
        toggleDragover(false);
        this.messageSection.innerHTML = "";

        const files = event.dataTransfer.files;
        if (files.length < 1) {
          return;
        }
        this.uploadFile(files[0]);
      }
    };
    Object.keys(dropEvents).forEach((key) => {
      this.dropZone.addEventListener(key, dropEvents[key]);
    });

    const handleClose = () => {
      const titleInput = this.inputSection.querySelector(".attachment-title");
      if (titleInput) {
        this.values.alt = titleInput.value;
      }

      if (this.onClose) {
        this.onClose(this);
      }
      if (this.callback) {
        this.callback(this.exitMode);
        this.callback = null;
      }
    };
    this.element.addEventListener("close.dialog", () => setTimeout(handleClose, 0));
  }

  getValue(key) {
    return this.values[key];
  }

  toggle(values = {}, options = {}) {
    this.exitMode = "cancel";

    return new Promise((resolve) => {
      this.saveButton.disabled = true;
      this.values = { src: values.src, alt: values.alt }

      this.updateCurrentFile();

      let titleEl = this.element.querySelector("[data-dialog-title]");

      if (values.src && values.src.length > 0) {
        titleEl.textContent = titleEl.dataset.editlabel;
      } else {
        titleEl.textContent = titleEl.dataset.addlabel;
      }

      const titleInputHtml = `
        <label>
          ${options.inputLabel}
          <input class="attachment-title" type="text" name="alt">
        </label>
      `;

      let titleSection = null;
      titleSection = createElement(`<div class="form__wrapper">${titleInputHtml}</div>`);
      titleSection.querySelector(".attachment-title").value = values.alt || "";
      this.inputSection.innerHTML = "";
      this.inputSection.append(titleSection);

      this.uploadHandler = options.uploadHandler;

      const dialogId = this.element.dataset.dialog;
      const dialog = window.Decidim.currentDialogs[dialogId];
      if (dialog) {
        dialog.open();
      } else {
        console.error(`Upload dialog not initialized for: ${dialogId}`);
      }

      this.callback = resolve;

      if (this.onOpen) {
        this.onOpen(this);
      }
    });
  }

  updateCurrentFile(file) {
    const items = this.dropZone.querySelector("[data-dropzone-items]");

    if (!this.values.src || this.values.src.length < 1) {
      items.setAttribute("hidden", "hidden");
      items.innerHTML = "";
      return;
    }

    this.saveButton.disabled = false;
    if (file) {
      items.removeAttribute("hidden");
      items.innerHTML = `
        <li data-filename="${file.name}" data-state="validated">
          <div data-template="ok">
            <div><img src="${this.values.src}" alt="${this.i18n.uploadedFile}"></div>
            <span>${file.name}</span>
          </div>
        </li>
      `;
    }
  }

  async uploadFile(file) {
    if (!this.uploadHandler) {
      return;
    }

    const response = await this.uploadHandler(file);
    if (!response.url) {
      const items = this.dropZone.querySelector("[data-dropzone-items]");
      const locales = JSON.parse(items.dataset.locales);
      items.removeAttribute("hidden");
      items.innerHTML = `
        <li data-filename="${file.name}" data-state="validated">
          <div data-template="error">
            <div>${icon("error-warning-line")}</div>
            <div>
              <span>${file.name}</span>
              <span>${locales.validation_error}</span>
              <ul><li>${response.message}</li></ul>
            </div>
          </div>
        </li>
      `;
      return;
    }
    this.values.src = response.url;

    const titleInput = this.inputSection.querySelector(".attachment-title");
    if (titleInput && (!titleInput.value || titleInput.value.length < 1)) {
      titleInput.value = fileNameToTitle(file.name);
    }

    this.updateCurrentFile(file);
  }
}
