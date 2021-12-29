import { Uploader } from "src/decidim/direct_uploads/uploader";

export default class UploadModal {
  constructor(button, options = {}) {
    console.log("LOAD");
    this.button = button;
    this.modal = document.querySelector(`#${button.dataset.open}`)
    this.resourceName = button.dataset.resourcename
    this.options = options;
    this.attachmentCounter = 0;
    this.name = this.button.name;
    this.multiple = this.button.dataset.multiple === "true";
    this.titled = this.button.dataset.titled === "true";
    this.dropZoneEnabled = true;
    this.modalTitle = this.modal.querySelector(".reveal__title");

    this.uploadItems = this.modal.querySelector(".upload-items");
    this.dropZone = this.modal.querySelector(".dropzone");
    this.input = this.dropZone.querySelector("input");

    this.uploadContainer = document.querySelector(`.upload-container-for-${this.name}`);
    this.activeAttachments = this.uploadContainer.querySelector(".active-attachments");
    this.removeButton = this.uploadContainer.querySelector("button.remove-attachment");
    this.trashCan = this.createTrashCan();
  }

  init() {
    this.loadAttachments();
    this.addInputEventListeners();
    this.addOpenModalButtonEventListeners();
    this.addDropzoneEventListeners();
    this.addSaveButtonEventListeners();
    this.initializeRemoveButton();
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

        const hiddenFieldsContainer = uploadItemComponent.querySelector(".attachment-details");
        hiddenFieldsContainer.classList.add(`pending-${this.name}`);

        const hiddenBlobField = document.createElement("input");
        hiddenBlobField.setAttribute("type", "hidden");
        hiddenBlobField.setAttribute("value", blob.signed_id);
        if (this.titled) {
          hiddenBlobField.name = `${this.resourceName}[${addAttribute}][${ordinalNumber}][file]`;
        } else {
          hiddenBlobField.name = `${this.resourceName}[${addAttribute}][file]`;
        }

        if (this.titled) {
          const hiddenTitleField = document.createElement("input");
          hiddenTitleField.classList.add("hidden-title");
          hiddenTitleField.setAttribute("type", "hidden");
          hiddenTitleField.setAttribute("value", file.name.split(".")[0]);
          hiddenTitleField.name = `${this.resourceName}[${addAttribute}][${ordinalNumber}][title]`;
          hiddenFieldsContainer.appendChild(hiddenTitleField);
        }

        hiddenFieldsContainer.appendChild(hiddenBlobField);
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

    const attachmentDetails = document.createElement("div");
    attachmentDetails.classList.add("attachment-details");
    attachmentDetails.setAttribute("data-filename", fileName);

    firstRow.appendChild(fileNameSpan);
    firstRow.appendChild(titleContainer);

    secondRow.appendChild(progressBarWrapper);
    secondRow.appendChild(tileInputContainer);
    secondRow.appendChild(removeField);

    wrapper.appendChild(firstRow);
    wrapper.appendChild(secondRow);
    wrapper.appendChild(attachmentDetails);

    this.uploadItems.appendChild(wrapper);

    return wrapper;
  }

  updateTitles() {
    this.uploadItems.querySelectorAll(".upload-item").forEach((uploadItem) => {
      const fileName = uploadItem.dataset.filename
      const updatedTitle = uploadItem.querySelector("input[type='text']").value;
      const attachmentWrapper = this.activeAttachments.querySelector(`[data-filename='${fileName}']`);
      const titleAndFilenameSpan = attachmentWrapper.querySelector("span");
      if (this.titled) {
        titleAndFilenameSpan.innerHTML = `${updatedTitle} (${fileName})`;
      } else {
        titleAndFilenameSpan.innerHTML = fileName;
      }
    })
  }

  updateAddAttachmentsButton() {
    if (this.activeAttachments.children.length === 0) {
      this.button.innerHTML = this.modalTitle.dataset.addlabel;
    } else {
      this.button.innerHTML = this.modalTitle.dataset.editlabel;
    }
  }

  createTrashCan() {
    const trashCan =  document.createElement("div");
    trashCan.classList.add("trash-can");
    trashCan.style.display = "none";
    this.uploadItems.parentElement.appendChild(trashCan);
    return trashCan;
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

  loadAttachments() {
    Array.from(this.activeAttachments.children).forEach((child) => {
      this.createUploadItemComponent(child.dataset.filename, child.dataset.title, "uploaded");
    })
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

  addSaveButtonEventListeners() {
    const saveButton = this.modal.querySelector(`.add-attachment-${this.name}`);
    saveButton.addEventListener("click", (event) => {
      event.preventDefault();
      this.uploadItems.querySelectorAll(".upload-item").forEach((item) => {
        const title = item.querySelector("input[type='text']").value;
        const titleAndFileNameSpan = document.createElement("span");
        titleAndFileNameSpan.innerHTML = `${title} (${item.dataset.filename})`;
        const attachmentDetails = item.querySelector(".attachment-details");
        attachmentDetails.appendChild(titleAndFileNameSpan);
        this.activeAttachments.appendChild(attachmentDetails);
        if (!this.titled) {
          this.removeButton.parentElement.style.display = "block";
        }
      })
      this.cleanTrashCan();
      this.updateTitles();
      this.updateAddAttachmentsButton();
    })
  }

  initializeRemoveButton() {
    if (this.titled || this.activeAttachments.children.length === 0) {
      this.removeButton.parentElement.style.display = "none";
    }
    this.removeButton.addEventListener("click", (event) => {
      event.preventDefault();

      this.removeButton.parentElement.style.display = "none";
      this.uploadItems.innerHTML = "";
      this.activeAttachments.innerHTML = `<input name='${this.resourceName}[remove_${this.name}]' type="hidden" value="true">`;
    })
  }
}
