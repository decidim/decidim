import { Uploader } from "src/decidim/direct_uploads/uploader";

export default class UploadModal {
  constructor(button, options = {}) {
    this.button = button;
    this.modal = document.querySelector(`#${button.dataset.open}`)
    this.resourceName = button.dataset.resourcename
    this.options = options;
    this.attachmentCounter = 0;
    this.name = this.button.name;
    this.multiple = this.button.dataset.multiple === "true";
    this.dropZoneEnabled = true;
    this.modalTitle = this.modal.querySelector(".reveal__title");

    this.uploadItems = this.modal.querySelector(".upload-items");
    this.dropZone = this.modal.querySelector(".dropzone");
    this.input = this.dropZone.querySelector("input");

    this.activeAttachments = document.querySelector(`.active-attachments-${this.name}`);
    this.pendingAttachments = document.querySelector(`.pending-attachments-${this.name}`);
    this.trashCan = this.createTrashCan();
  }

  init() {
    this.loadAttachments();
    this.addInputEventListeners();
    this.addOpenModalButtonEventListeners();
    this.addDropzoneEventListeners();
    this.addSaveButtonEventListeners();
  }

  createTrashCan() {
    const trashCan =  document.createElement("div");
    trashCan.classList.add("trash-can");
    trashCan.style.display = "none";
    this.uploadItems.parentElement.appendChild(trashCan);
    return trashCan;
  }

  loadAttachments() {
    Array.from(this.activeAttachments.children).forEach((child) => {
      this.createUploadItemComponent(child.dataset.filename, child.dataset.title, "uploaded");
    })
  }

  uploadFile(file) {
    if (!this.dropZoneEnabled) {
      return;
    }

    const uploadItemComponent = this.createUploadItemComponent(file.name, file.name.split(".")[0], "init");
    const uploader = new Uploader(file, uploadItemComponent, {
      url: this.input.dataset.directuploadurl,
      attachmentName: file.name
    });

    uploader.upload.create((error, blob) => {
      if (error) {
        uploadItemComponent.dataset.state = "error";
        uploadItemComponent.querySelector(".progress-bar").style.width = "100%";
        uploadItemComponent.querySelector(".progress-bar").innerHTML = "Error";
        console.error(error);
      } else {
        const inputName = this.input.name;
        const addAttribute = inputName.substring(inputName.indexOf("[") + 1, inputName.indexOf("]"));
        const ordinalNumber = this.attachmentCounter;
        this.attachmentCounter += 1;

        const hiddenFieldsContainer = uploadItemComponent.querySelector(".hidden-fields-container");
        hiddenFieldsContainer.classList.add(`pending-${this.name}`);

        const hiddenBlobField = document.createElement("input");
        hiddenBlobField.setAttribute("type", "hidden");
        hiddenBlobField.setAttribute("value", blob.signed_id);
        hiddenBlobField.name = `${this.resourceName}[${addAttribute}][${ordinalNumber}][file]`;

        const hiddenTitleField = document.createElement("input");
        hiddenTitleField.classList.add("hidden-title");
        hiddenTitleField.setAttribute("type", "hidden");
        hiddenTitleField.setAttribute("value", file.name.split(".")[0]);
        hiddenTitleField.name = `${this.resourceName}[${addAttribute}][${ordinalNumber}][title]`;

        hiddenFieldsContainer.appendChild(hiddenBlobField);
        hiddenFieldsContainer.appendChild(hiddenTitleField);
        uploadItemComponent.appendChild(hiddenFieldsContainer)
      }
    });
    this.updateDropZone();
  }

  updateDropZone() {
    if (this.multiple) {
      return;
    }

    if (this.uploadItems.children.length > 0) {
      this.dropZone.classList.add("disabled");
      this.dropZoneEnabled = false;
      this.input.disabled = true;
    } else {
      this.dropZone.classList.remove("disabled");
      this.dropZoneEnabled = true;
      this.input.disabled = false;
    }
  }

  createUploadItemComponent(fileName, title, state) {
    const wrapper = document.createElement("div");
    wrapper.classList.add("upload-item");
    wrapper.setAttribute("data-filename", fileName);

    const firstRow = document.createElement("div");
    firstRow.classList.add("row");
    const secondRow = document.createElement("div");
    secondRow.classList.add("row");

    const fileNameSpan = document.createElement("span");
    fileNameSpan.classList.add("columns", "small-4");
    fileNameSpan.innerHTML = fileName;

    const titleSpan = document.createElement("span");
    titleSpan.innerHTML = "Title";

    const titleContainer = document.createElement("div");
    titleContainer.classList.add("columns", "small-8");
    titleContainer.appendChild(titleSpan);

    const progressBar = document.createElement("div");
    progressBar.classList.add("progress-bar");
    if (state) {
      progressBar.innerHTML = state;
      progressBar.style.justifyContent = "center";
    }

    const progressBarBorder = document.createElement("div");
    progressBarBorder.classList.add("progress-bar-border");
    progressBarBorder.appendChild(progressBar);

    const progressBarWrapper = document.createElement("div");
    progressBarWrapper.classList.add("columns", "small-4");
    progressBarWrapper.appendChild(progressBarBorder);

    const titleInput = document.createElement("input");
    titleInput.type = "text";
    titleInput.value = title;

    const tileInputContainer = document.createElement("div");
    tileInputContainer.classList.add("columns", "small-5");
    tileInputContainer.appendChild(titleInput);

    const removeField = document.createElement("span");
    removeField.classList.add("columns", "small-3", "remove-upload-item");
    removeField.innerHTML = "&times; Remove";
    removeField.addEventListener(("click"), (event) => {
      event.preventDefault();
      const item = this.uploadItems.querySelector(`[data-filename='${fileName}']`);
      this.trashCan.append(item);
      this.updateDropZone();
    })

    const hiddenFieldsContainer = document.createElement("div");
    hiddenFieldsContainer.classList.add("hidden-fields-container");
    hiddenFieldsContainer.setAttribute("data-filename", fileName);

    firstRow.appendChild(fileNameSpan);
    firstRow.appendChild(titleContainer);

    secondRow.appendChild(progressBarWrapper);
    secondRow.appendChild(tileInputContainer);
    secondRow.appendChild(removeField);

    wrapper.appendChild(firstRow);
    wrapper.appendChild(secondRow);
    wrapper.appendChild(hiddenFieldsContainer);

    this.uploadItems.appendChild(wrapper);

    return wrapper;
  }

  addInputEventListeners() {
    this.input.addEventListener("change", (event) => {
      event.preventDefault();
      const files = event.target.files;
      Array.from(files).forEach((file) => this.uploadFile(file));
    })
  }

  addOpenModalButtonEventListeners() {
    this.button.addEventListener("click", (event) => {
      event.preventDefault();
      Array.from(this.trashCan.children).forEach((item) => {
        this.uploadItems.append(item);
      })
      if (this.uploadItems.children.length === 0) {
        this.modalTitle.innerHTML = this.modalTitle.dataset.addlabel;
      } else {
        this.modalTitle.innerHTML = this.modalTitle.dataset.editlabel;
      }
      this.updateDropZone();
    })
  }

  addSaveButtonEventListeners() {
    const saveButton = this.modal.querySelector(`.add-attachment-${this.name}`);
    saveButton.addEventListener("click", (event) => {
      event.preventDefault();
      this.uploadItems.querySelectorAll(".upload-item").forEach((item) => {
        const title = item.querySelector("input[type='text']").value;
        const titleAndFileNameSpan = document.createElement("span");
        titleAndFileNameSpan.innerHTML = `${title} (${item.dataset.filename})`;
        const hiddenFieldsContainer = item.querySelector(".hidden-fields-container");
        this.activeAttachments.appendChild(hiddenFieldsContainer);
      })
      this.cleanTrashCan();
      this.updateTitles();
      this.updateAddAttachmentsButton();
    })
  }

  cleanTrashCan() {
    Array.from(this.trashCan.children).forEach((item) => {
      const fileName = item.dataset.filename;
      const activeAttachment = this.activeAttachments.querySelector(`div[data-filename='${fileName}']`);
      if (activeAttachment) {
        activeAttachment.remove();
      }
      item.remove();
    })
  }

  updateTitles() {
    this.uploadItems.querySelectorAll(".upload-item").forEach((fileField) => {
      const fileName = fileField.dataset.filename
      const updatedTitle = fileField.querySelector("input[type='text']").value;
      const attachmentWrapper = this.activeAttachments.querySelector(`[data-filename='${fileName}']`);
      const titleAndFilenameSpan = attachmentWrapper.querySelector("span");
      titleAndFilenameSpan.innerHTML = `${updatedTitle} (${fileName})`;
    })
  }

  updateAddAttachmentsButton() {
    if (this.activeAttachments.children.length === 0) {
      this.button.innerHTML = this.modalTitle.dataset.addlabel;
    } else {
      this.button.innerHTML = this.modalTitle.dataset.editlabel;
    }
  }

  addDropzoneEventListeners() {
    this.dropZone.addEventListener("dragenter", (event) => {
      event.preventDefault();
    })

    this.dropZone.addEventListener("dragover", (event) => {
      event.preventDefault();
      this.dropZone.classList.add("is-dragover");
    })

    this.dropZone.addEventListener("dragleave", () => {
      this.dropZone.classList.remove("is-dragover");
    })

    this.dropZone.addEventListener("drop", (event) => {
      event.preventDefault();
      const files = event.dataTransfer.files;
      Array.from(files).forEach((file) => this.uploadFile(file));
    })
  }
}
