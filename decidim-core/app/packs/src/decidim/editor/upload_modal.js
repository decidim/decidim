const createElement = (template) => {
  const el = document.createElement("div");
  el.innerHTML = template;
  return el.firstElementChild;
}

/**
 * This is a simplified version of the normal upload modal, uses the same
 * markup as the normal upload modal to maintain consistency.
 *
 * The functionality differs from the original modal as this only handles the
 * file uploads for the editor and the purpose is to simply provide the same
 * upload functionality and ability to update the alternative texts for the
 * images within the editor.
 *
 * This works only for the editor and does not store the files in the view
 * inputs as they are only used.
 */
export default class UploadModal {
  constructor(element) {
    this.element = element;

    this.values = { src: null, alt: null };
    this.dropZoneEnabled = true;
    this.exitMode = "cancel";
    this.saveButton = this.element.querySelector("button.add-file-file");
    this.cancelButton = this.element.querySelector("button.cancel-attachment");
    this.dropZone = this.element.querySelector(".dropzone");
    this.messageSection = document.createElement("div");
    this.currentFileSection = document.createElement("div");
    this.inputSection = document.createElement("div");

    const dc = this.element.querySelector(".dropzone-container");
    const extra = document.createElement("div");
    dc.parentNode.insertBefore(extra, dc.nextSibling);
    extra.append(this.messageSection);
    extra.append(this.currentFileSection);
    extra.append(this.inputSection);

    this.saveButton.addEventListener("click", () => {
      this.exitMode = "save";
    });
    this.cancelButton.addEventListener("click", () => {
      this.exitMode = "cancel";
    });

    const dropEvents = {
      dragenter: (event) => event.preventDefault(),
      dragleave: () => this.dropZone.classList.remove("is-dragover"),
      dragover: (event) => {
        event.preventDefault();
        this.dropZone.classList.add("is-dragover");
      },
      drop: (event) => {
        event.preventDefault();
        this.dropZone.classList.remove("is-dragover");
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

    $(this.element).on("closed.zf.reveal", () => {
      const titleInput = this.inputSection.querySelector(".attachment-title");
      if (titleInput) {
        this.values.alt = titleInput.value;
      }

      if (this.callback) {
        this.callback(this.exitMode);
        this.callback = null;
      }
    });
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

      const titleEl = this.element.querySelector(".reveal__title");
      if (values.src && values.src.length > 0) {
        titleEl.innerText = titleEl.dataset.editlabel;
      } else {
        titleEl.innerText = titleEl.dataset.addlabel;
      }

      const titleSection = createElement(`
        <div class="row">
          <label>
            ${options.inputLabel}
            <input class="attachment-title" type="text" name="alt">
          </label>
        </div>
      `);
      titleSection.querySelector(".attachment-title").value = values.alt || "";
      this.inputSection.innerHTML = "";
      this.inputSection.append(titleSection);

      this.uploadHandler = options.uploadHandler;
      $(this.element).foundation("open");

      this.callback = resolve;
    });
  }

  updateCurrentFile() {
    if (!this.values.src || this.values.src.length < 1) {
      this.currentFileSection.innerHTML = "";
      return;
    }

    this.saveButton.disabled = false;
    this.currentFileSection.innerHTML = `
      <img src="${this.values.src}" alt="Uploaded file" style="max-width:100px">
    `;
  }

  async uploadFile(file) {
    if (!this.uploadHandler) {
      return;
    }

    const response = await this.uploadHandler(file);
    if (!response.url) {
      this.messageSection.innerHTML = `<div class="form-error is-visible">${response.message}</div>`;
      return;
    }
    this.values.src = response.url;

    const titleInput = this.inputSection.querySelector(".attachment-title");
    if (titleInput && (!titleInput.value || titleInput.value.length < 1)) {
      titleInput.value = file.name.split(".")[0];
    }

    this.updateCurrentFile();
  }
}
