import { Uploader } from "src/decidim/direct_uploads/uploader";

export default class UploadModal {
  constructor(button, options = {}) {
    this.button = button;
    this.modal = document.querySelector(`#${button.dataset.open}`)
    this.resourceName = button.dataset.resourcename
    this.options = options;
    this.attachmentCounter = 0;
    this.name = this.button.name;
    // this.container = this.modal.querySelector(`div[data-name='${this.name}']`)

    this.uploadItems = this.modal.querySelector(".upload-items");
    this.dropZone = this.modal.querySelector(".dropzone");
    this.input = this.dropZone.querySelector("input");

    this.activeAttachments = document.querySelector(`.active-attachments-${this.name}`);
    this.pendingAttachments = document.querySelector(`.pending-attachments-${this.name}`);
  }

  init() {
    this.loadAttachments();
    this.addInputEventListeners();
    this.addDropzoneEventListeners();
    this.addSaveButtonEventListeners();
  }

  loadAttachments() {
    Array.from(this.activeAttachments.children).forEach((child) => {
      this.createUploadItemComponent(child.dataset.filename, child.dataset.title, true);
    })
  }

  uploadFile(file) {
    console.log("file", file);
    const uploadItemComponent = this.createUploadItemComponent(file.name, file.name.split(".")[0])
    const uploader = new Uploader(file, uploadItemComponent, {
      url: this.input.dataset.directuploadurl,
      attachmentName: file.name
    });

    uploader.upload.create((error, blob) => {
      if (error) {
        uploadItemComponent.querySelector(".progress-bar").style.width = "100%"
        uploadItemComponent.querySelector(".progress-bar").innerHTML = "Error";
        console.error(error);
      } else {
        // Add an appropriately-named hidden input to the form with a
        //  value of blob.signed_id so that the blob ids will be
        //  transmitted in the normal upload flow
        console.log("this.name", this.name)
        const ordinalNumber = this.attachmentCounter;
        this.attachmentCounter += 1;
        const hiddenFieldsContainer = document.createElement("div");
        hiddenFieldsContainer.setAttribute("display", "none");
        hiddenFieldsContainer.setAttribute("data-filename", file.name);
        hiddenFieldsContainer.classList.add(`pending-${this.name}`);

        const hiddenBlobField = document.createElement("input");
        hiddenBlobField.setAttribute("type", "hidden");
        hiddenBlobField.setAttribute("value", blob.signed_id);
        hiddenBlobField.name = `${this.resourceName}[add_${this.name}][${ordinalNumber}][file]`;

        const hiddenTitleField = document.createElement("input");
        hiddenTitleField.classList.add("hidden-title");
        hiddenTitleField.setAttribute("type", "hidden");
        hiddenTitleField.setAttribute("value", file.name.split(".")[0]);
        hiddenTitleField.name = `${this.resourceName}[add_${this.name}][${ordinalNumber}][title]`;

        hiddenFieldsContainer.appendChild(hiddenBlobField);
        hiddenFieldsContainer.appendChild(hiddenTitleField);
        this.pendingAttachments.appendChild(hiddenFieldsContainer);
      }
    });
  }

  createUploadItemComponent(fileName, title, uploaded) {
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
    if (uploaded) {
      progressBar.innerHTML = "uploaded";
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
    removeField.addEventListener(("click"), () => {
      console.log("click")
      const item = this.uploadItems.querySelector(`[data-filename='${fileName}']`)
      console.log("item", item);
      item.setAttribute("data-deleted", "true");
      item.style.display = "none";
    })

    firstRow.appendChild(fileNameSpan);
    firstRow.appendChild(titleContainer);

    secondRow.appendChild(progressBarWrapper);
    secondRow.appendChild(tileInputContainer);
    secondRow.appendChild(removeField);

    wrapper.appendChild(firstRow);
    wrapper.appendChild(secondRow);

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

  addSaveButtonEventListeners() {
    const saveButton = this.modal.querySelector(`.add-attachment-${this.name}`);
    saveButton.addEventListener("click", (event) => {
      event.preventDefault();
      Array.from(this.pendingAttachments.children).forEach((child) => {
        const hiddenTitleInput = child.querySelector(".hidden-title");
        const titleAndFileNameSpan = document.createElement("span");
        titleAndFileNameSpan.innerHTML = `${hiddenTitleInput.value} (${child.dataset.filename})`;
        child.className = `active-${this.name}`;
        child.append(titleAndFileNameSpan);
        this.activeAttachments.append(child);
      })
      this.updateDeleted();
      this.updateTitles();
      this.updateAddAttachmentsButton();
    })
  }

  updateDeleted() {
    this.uploadItems.querySelectorAll(".upload-item[data-deleted='true'").forEach((item) => {
      const fileName = item.dataset.filename;
      const activeAttachment = this.activeAttachments.querySelector(`div[data-filename='${fileName}']`)
      console.log("activeAttachment", activeAttachment)
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
      const hiddenTitleField = attachmentWrapper.querySelector(".hidden-title");
      const titleAndFilenameSpan = attachmentWrapper.querySelector("span");
      hiddenTitleField.value = updatedTitle;
      titleAndFilenameSpan.innerHTML = `${updatedTitle} (${fileName})`;
    })
  }

  updateAddAttachmentsButton() {
    if (this.activeAttachments.children.length === 0) {
      this.button.innerHTML = `Add ${this.name}`;
    } else {
      this.button.innerHTML = `Edit ${this.name}`;
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
