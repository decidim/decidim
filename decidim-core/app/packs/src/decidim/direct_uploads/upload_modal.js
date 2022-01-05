import { Uploader } from "src/decidim/direct_uploads/uploader";

export default class UploadModal {
  constructor(button, options = {}) {
    this.button = button;
    this.options = options;
    this.modal = document.querySelector(`#${button.dataset.open}`);
    this.resourceName = button.dataset.resourceName;
    this.resourceClass = button.dataset.resourceClass;
    this.maxFileSize = button.dataset.maxFileSize;
    this.attachmentCounter = 0;
    this.name = this.button.name;
    this.multiple = this.button.dataset.multiple === "true";
    this.titled = this.button.dataset.titled === "true";
    this.dropZoneEnabled = true;
    this.modalTitle = this.modal.querySelector(".reveal__title");

    this.uploadItems = this.modal.querySelector(".upload-items");
    this.locales = JSON.parse(this.uploadItems.dataset.locales);
    this.dropZone = this.modal.querySelector(".dropzone");
    this.input = this.dropZone.querySelector("input");
    this.addAttribute = this.input.name.substring(this.input.name.indexOf("[") + 1, this.input.name.indexOf("]"));

    this.uploadContainer = document.querySelector(`.upload-container-for-${this.name}`);
    this.activeAttachments = this.uploadContainer.querySelector(".active-attachments");
    this.removeButton = this.uploadContainer.querySelector("button.remove-attachment");
    this.trashCan = this.createTrashCan();
  }

  uploadFile(file) {
    if (!this.dropZoneEnabled) {
      return;
    }

    const uploadItem = this.createUploadItem(file.name, file.name.split(".")[0], "init");
    const uploader = new Uploader(this, uploadItem, {
      file: file,
      url: this.input.dataset.directuploadurl,
      attachmentName: file.name
    });
    if (uploader.fileTooBig) {
      return;
    }
    uploader.upload.create((error, blob) => {
      if (error) {
        uploadItem.dataset.state = "error";
        uploadItem.querySelector(".progress-bar").style.width = "100%";
        uploadItem.querySelector(".progress-bar").innerHTML = this.locales.error;
        console.error(error);
      } else {
        const ordinalNumber = this.attachmentCounter;
        this.attachmentCounter += 1;

        const attachmentDetails = document.createElement("div");
        attachmentDetails.classList.add("attachment-details");
        attachmentDetails.dataset.filename = file.name;
        const titleAndFileNameSpan = document.createElement("span");
        titleAndFileNameSpan.style.display = "none";
        attachmentDetails.appendChild(titleAndFileNameSpan);

        const hiddenBlobField = document.createElement("input");
        hiddenBlobField.setAttribute("type", "hidden");
        hiddenBlobField.setAttribute("value", blob.signed_id);
        if (this.titled) {
          hiddenBlobField.name = `${this.resourceName}[${this.addAttribute}][${ordinalNumber}][file]`;
        } else {
          hiddenBlobField.name = `${this.resourceName}[${this.addAttribute}]`;
        }

        if (this.titled) {
          const title = file.name.split(".")[0];
          const hiddenTitleField = document.createElement("input");
          hiddenTitleField.classList.add("hidden-title");
          hiddenTitleField.setAttribute("type", "hidden");
          hiddenTitleField.setAttribute("value", title);
          hiddenTitleField.name = `${this.resourceName}[${this.addAttribute}][${ordinalNumber}][title]`;
          titleAndFileNameSpan.innerHTML = `${title} (${file.name})`;
          attachmentDetails.appendChild(hiddenTitleField);
        } else {
          titleAndFileNameSpan.innerHTML = file.name;
        }

        if (!this.multiple) {
          this.cleanTrashCan();
        }

        attachmentDetails.appendChild(hiddenBlobField);
        uploadItem.appendChild(attachmentDetails);
        // Fix to event
        uploader.validate(blob.signed_id);
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

  createUploadItem(fileName, title, state) {
    const wrapper = document.createElement("div");
    wrapper.classList.add("upload-item");
    wrapper.setAttribute("data-filename", fileName);

    const firstRow = document.createElement("div");
    firstRow.classList.add("first-row");
    const secondRow = document.createElement("div");
    secondRow.classList.add("second-row");

    const fileNameSpan = document.createElement("span");
    fileNameSpan.innerHTML = fileName;

    const progressBar = document.createElement("div");
    progressBar.classList.add("progress-bar");
    if (state) {
      if (state === "validated") {
        progressBar.innerHTML = this.locales.uploaded;
      }
      progressBar.style.justifyContent = "center";
      wrapper.dataset.state = state;
    }

    const progressBarBorder = document.createElement("div");
    progressBarBorder.classList.add("progress-bar-border");
    progressBarBorder.appendChild(progressBar);

    const progressBarWrapper = document.createElement("div");
    progressBarWrapper.classList.add("progress-bar-wrapper");
    progressBarWrapper.appendChild(progressBarBorder);

    let tileInputContainer = null;
    if (this.titled) {
      const titleInput = document.createElement("input");
      titleInput.type = "text";
      titleInput.value = title;
      tileInputContainer = document.createElement("div");
      tileInputContainer.appendChild(titleInput);
    }

    const errorList = document.createElement("ul");
    errorList.className = "upload-errors";

    const removeField = document.createElement("span");
    removeField.classList.add("remove-upload-item");
    removeField.innerHTML = `&times; ${this.locales.remove}`;
    removeField.addEventListener(("click"), (event) => {
      event.preventDefault();
      const item = this.uploadItems.querySelector(`[data-filename='${fileName}']`);
      this.trashCan.append(item);
      this.updateDropZone();
    })

    const titleAndFileNameSpan = document.createElement("span");
    titleAndFileNameSpan.innerHTML = `${title} (${fileName})`;

    firstRow.appendChild(fileNameSpan);

    secondRow.appendChild(progressBarWrapper);
    if (this.titled) {
      const titleSpan = document.createElement("span");
      titleSpan.innerHTML = "Title";

      const titleContainer = document.createElement("div");
      titleContainer.appendChild(titleSpan);
      firstRow.appendChild(titleContainer);
      secondRow.appendChild(tileInputContainer);
    }
    secondRow.appendChild(removeField);
    secondRow.appendChild(errorList);

    wrapper.appendChild(firstRow);
    wrapper.appendChild(secondRow);

    this.uploadItems.appendChild(wrapper);

    return wrapper;
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
}
