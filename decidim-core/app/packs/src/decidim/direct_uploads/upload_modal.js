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
    this.titled = this.button.dataset.titled === "true";
    this.dropZoneEnabled = true;
    this.modalTitle = this.modal.querySelector(".reveal__title");

    this.uploadItems = this.modal.querySelector(".upload-items");
    this.dropZone = this.modal.querySelector(".dropzone");
    this.input = this.dropZone.querySelector("input");

    this.uploadContainer = document.querySelector(`.upload-container-for-${this.name}`);
    if (this.titled) {
      this.uploadContainer.classList.add("with-title");
    }
    this.activeAttachments = this.uploadContainer.querySelector(".active-attachments");
    this.removeButton = this.uploadContainer.querySelector("button.remove-attachment");
    this.trashCan = this.createTrashCan();
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

        const attachmentDetails = document.createElement("div");
        attachmentDetails.classList.add("attachment-details");
        attachmentDetails.dataset.filename = file.name;
        const titleAndFileNameSpan = document.createElement("span");
        attachmentDetails.style.display = "none";
        attachmentDetails.appendChild(titleAndFileNameSpan);

        const hiddenBlobField = document.createElement("input");
        hiddenBlobField.setAttribute("type", "hidden");
        hiddenBlobField.setAttribute("value", blob.signed_id);
        if (this.titled) {
          hiddenBlobField.name = `${this.resourceName}[${addAttribute}][${ordinalNumber}][file]`;
        } else {
          hiddenBlobField.name = `${this.resourceName}[${addAttribute}]`;
        }

        if (this.titled) {
          const title = file.name.split(".")[0];
          const hiddenTitleField = document.createElement("input");
          hiddenTitleField.classList.add("hidden-title");
          hiddenTitleField.setAttribute("type", "hidden");
          hiddenTitleField.setAttribute("value", title);
          hiddenTitleField.name = `${this.resourceName}[${addAttribute}][${ordinalNumber}][title]`;
          titleAndFileNameSpan.innerHTML = `${title} (${file.name})`;
          attachmentDetails.appendChild(hiddenTitleField);
        } else {
          titleAndFileNameSpan.innerHTML = file.name;
        }

        if (!this.multiple) {
          this.cleanTrashCan();
        }

        attachmentDetails.appendChild(hiddenBlobField);
        uploadItemComponent.appendChild(attachmentDetails)
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

    let tileInputContainer = null;
    if (this.titled) {
      const titleInput = document.createElement("input");
      titleInput.type = "text";
      titleInput.value = title;
      tileInputContainer = document.createElement("div");
      tileInputContainer.classList.add("columns", "small-5");
      tileInputContainer.appendChild(titleInput);
    }

    const removeField = document.createElement("span");
    removeField.classList.add("columns", "small-3", "remove-upload-item");
    removeField.innerHTML = "&times; Remove";
    removeField.addEventListener(("click"), (event) => {
      event.preventDefault();
      const item = this.uploadItems.querySelector(`[data-filename='${fileName}']`);
      this.trashCan.append(item);
      this.updateDropZone();
    })

    const titleAndFileNameSpan = document.createElement("span");
    titleAndFileNameSpan.innerHTML = `${title} (${fileName})`;

    firstRow.appendChild(fileNameSpan);
    firstRow.appendChild(titleContainer);

    secondRow.appendChild(progressBarWrapper);
    if (this.titled) {
      secondRow.appendChild(tileInputContainer);
    }
    secondRow.appendChild(removeField);

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
