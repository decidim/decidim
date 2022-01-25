import { Uploader } from "src/decidim/direct_uploads/uploader";


// This class handles logic inside upload modal, but since modal is not inside the form
// logic here moves "upload items" / hidden inputs to form.
export default class UploadModal {
  constructor(button, options = {}) {
    // Button that opens the modal.
    this.button = button;
    this.options = Object.assign({
      // Field name / attribute of resource (e.g. avatar)
      addAttribute: button.dataset.addAttribute,
      // The resource to which the attribute belongs (e.g. user)
      resourceName: button.dataset.resourceName,
      // Ruby class of the resource (e.g. Decidim::User)
      resourceClass: button.dataset.resourceClass,
      // Defines if file is optional
      optional: button.dataset.optional === "true",
      // Defines if multiple files can be uploaded
      multiple: button.dataset.multiple === "true",
      // Defines if file(s) can have titles
      titled: button.dataset.titled === "true",
      // Defines maximum file size in bytes
      maxFileSize: button.dataset.maxFileSize,
      // Class of the current form object (e.g. Decidim::AccountForm)
      formObjectClass: button.dataset.formObjectClass
    }, options)

    this.name = this.button.name;
    this.modal = document.querySelector(`#${button.dataset.open}`);
    this.attachmentCounter = 0;
    this.dropZoneEnabled = true;
    this.modalTitle = this.modal.querySelector(".reveal__title");
    this.uploadItems = this.modal.querySelector(".upload-items");
    this.locales = JSON.parse(this.uploadItems.dataset.locales);
    this.dropZone = this.modal.querySelector(".dropzone");
    this.input = this.dropZone.querySelector("input");
    this.uploadContainer = document.querySelector(`.upload-container-for-${this.name}`);
    this.activeAttachments = this.uploadContainer.querySelector(".active-attachments");
    this.trashCan = this.createTrashCan();
  }

  uploadFile(file) {
    if (!this.dropZoneEnabled) {
      return;
    }

    const title = file.name.split(".")[0].slice(0, 31);
    const uploadItem = this.createUploadItem(file.name, title, "init");
    const uploader = new Uploader(this, uploadItem, {
      file: file,
      url: this.input.dataset.directUploadUrl,
      attachmentName: file.name
    });
    if (uploader.fileTooBig) {
      return;
    }

    uploader.upload.create((error, blob) => {
      if (error) {
        uploadItem.dataset.state = "error";
        const progressBar = uploadItem.querySelector(".progress-bar");
        progressBar.classList.add("filled");
        progressBar.innerHTML = this.locales.error;
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
        if (this.options.titled) {
          hiddenBlobField.name = `${this.options.resourceName}[${this.options.addAttribute}][${ordinalNumber}][file]`;
        } else {
          hiddenBlobField.name = `${this.options.resourceName}[${this.options.addAttribute}]`;
        }

        if (this.options.titled) {
          const hiddenTitleField = document.createElement("input");
          hiddenTitleField.classList.add("hidden-title");
          hiddenTitleField.setAttribute("type", "hidden");
          hiddenTitleField.setAttribute("value", title);
          hiddenTitleField.name = `${this.options.resourceName}[${this.options.addAttribute}][${ordinalNumber}][title]`;
          titleAndFileNameSpan.innerHTML = `${title} (${file.name})`;
          attachmentDetails.appendChild(hiddenTitleField);
        } else {
          titleAndFileNameSpan.innerHTML = file.name;
        }

        if (!this.options.multiple) {
          this.cleanTrashCan();
        }

        attachmentDetails.appendChild(hiddenBlobField);
        uploadItem.appendChild(attachmentDetails);
        uploader.validate(blob.signed_id);
      }
    });
    this.updateDropZone();
  }

  updateDropZone() {
    if (this.options.multiple) {
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
    const secondRow = document.createElement("div");
    const thirdRow = document.createElement("div");
    firstRow.classList.add("row", "upload-item-first-row");
    secondRow.classList.add("row", "upload-item-second-row");
    thirdRow.classList.add("row", "upload-item-third-row");

    const fileNameSpan = document.createElement("span");
    let fileNameSpanClasses = ["columns", "file-name-span"];
    if (this.options.titled) {
      fileNameSpanClasses.push("small-4", "medium-5");
    } else {
      fileNameSpanClasses.push("small-12");
    }
    fileNameSpan.classList.add(...fileNameSpanClasses);
    fileNameSpan.innerHTML = this.truncateFilename(fileName);

    const progressBar = document.createElement("div");
    progressBar.classList.add("progress-bar");
    if (state) {
      if (state === "validated") {
        progressBar.innerHTML = this.locales.uploaded;
      } else {
        progressBar.innerHTML = "0%";
        progressBar.style.width = "15%";
      }
      wrapper.dataset.state = state;
    }

    const progressBarBorder = document.createElement("div");
    progressBarBorder.classList.add("progress-bar-border");
    progressBarBorder.appendChild(progressBar);

    const progressBarWrapper = document.createElement("div");
    progressBarWrapper.classList.add("columns", "progress-bar-wrapper");
    progressBarWrapper.appendChild(progressBarBorder);
    if (this.options.titled) {
      progressBarWrapper.classList.add("small-4", "medium-5");
    } else {
      progressBarWrapper.classList.add("small-10");
    }

    const errorList = document.createElement("ul");
    errorList.classList.add("upload-errors");

    const removeButton = document.createElement("button");
    removeButton.classList.add("columns", "small-3", "medium-2", "remove-upload-item");
    removeButton.innerHTML = `&times; ${this.locales.remove}`;
    removeButton.addEventListener(("click"), (event) => {
      event.preventDefault();
      const item = this.uploadItems.querySelector(`[data-filename='${fileName}']`);
      this.trashCan.append(item);
      this.updateDropZone();
    })

    const titleAndFileNameSpan = document.createElement("span");
    titleAndFileNameSpan.classList.add("columns", "small-5", "title-and-filename-span");
    titleAndFileNameSpan.innerHTML = `${title} (${this.truncateFilename(fileName)})`;

    firstRow.appendChild(fileNameSpan);
    secondRow.appendChild(progressBarWrapper);
    thirdRow.appendChild(errorList);

    let tileInputContainer = null;
    if (this.options.titled) {
      const titleInputContainer = document.createElement("input");
      titleInputContainer.classList.add("attachment-title");
      titleInputContainer.type = "text";
      titleInputContainer.value = title;
      tileInputContainer = document.createElement("div");
      tileInputContainer.classList.add("columns", "small-5", "title-input-container");
      tileInputContainer.appendChild(titleInputContainer);
      const titleLabelSpan = document.createElement("span");
      titleLabelSpan.classList.add("title-label-span");
      titleLabelSpan.innerHTML = this.locales.title;

      const titleContainer = document.createElement("div");
      titleContainer.classList.add("columns", "small-8", "medium-7", "title-container");
      titleContainer.appendChild(titleLabelSpan);
      firstRow.appendChild(titleContainer);
      secondRow.appendChild(tileInputContainer);
    }

    secondRow.appendChild(removeButton);

    wrapper.appendChild(firstRow);
    wrapper.appendChild(secondRow);
    wrapper.appendChild(thirdRow);

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

  truncateFilename(filename, maxLength = 31) {
    if (filename.length <= maxLength) {
      return filename;
    }

    const charactersFromBegin = Math.floor(maxLength / 2) - 3;
    const charactersFromEnd = maxLength - charactersFromBegin - 3;
    return `${filename.slice(0, charactersFromBegin)}...${filename.slice(-charactersFromEnd)}`;
  }
}
