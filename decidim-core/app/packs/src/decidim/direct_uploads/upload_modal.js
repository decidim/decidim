import { Uploader } from "src/decidim/direct_uploads/uploader";

export default class UploadModal {
  constructor(button, options = {}) {
    this.button = button;
    this.options = options;
    this.attachmentCounter = 0;
    this.name = this.button.name;
    this.container = document.querySelector(`div[data-name='${this.name}']`)
    this.dropZone = this.container.querySelector(".dropzone");
    this.input = this.container.querySelector("input");
    this.attachments = document.querySelector(`.added-attachments-${this.name}`);
  }

  init() {
    this.loadAttachments();
    this.addDropzoneEventListeners();
    this.addSaveButtonEventListeners();
  }

  loadAttachments() {
    Array.from(this.attachments.children).forEach((child) => {
      this.createFileFields(child.dataset.filename, child.dataset.title, true);
    })
  }

  uploadFile(file) {
    console.log("file", file);
    const fileFields = this.createFileFields(file.name, file.name.split(".")[0])
    const uploader = new Uploader(file, fileFields, {
      url: this.input.dataset.directuploadurl,
      token: "abcd1234",
      attachmentName: file.name
    });

    uploader.upload.create((error, blob) => {
      console.log("upload started");
      if (error) {
        console.log("this is error");
        console.error(error);
      } else {
        // Add an appropriately-named hidden input to the form with a
        //  value of blob.signed_id so that the blob ids will be
        //  transmitted in the normal upload flow
        console.log("this.name", this.name)
        const ordinalNumber = this.attachmentCounter;
        this.attachmentCounter += 1;
        const hiddenFieldsContainer = document.createElement("div");
        hiddenFieldsContainer.setAttribute("data-filename", file.name);
        hiddenFieldsContainer.classList.add(`pending-${this.name}`);

        const hiddenBlobField = document.createElement("input");
        hiddenBlobField.setAttribute("type", "hidden");
        hiddenBlobField.setAttribute("value", blob.signed_id);
        hiddenBlobField.name = `proposal[add_${this.name}][${ordinalNumber}][file]`;

        const hiddenTitleField = document.createElement("input");
        hiddenTitleField.setAttribute("type", "hidden");
        hiddenTitleField.setAttribute("value", file.name.split(".")[0]);
        hiddenTitleField.name = `proposal[add_${this.name}][${ordinalNumber}][title]`;

        hiddenFieldsContainer.appendChild(hiddenBlobField);
        hiddenFieldsContainer.appendChild(hiddenTitleField);
        this.container.appendChild(hiddenFieldsContainer);
      }
    });
  }

  createFileFields(fileName, title, ready) {
    const wrapper = document.createElement("div");
    wrapper.classList.add("file-fields");

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
    if (ready) {
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
    removeField.classList.add("columns", "small-3");
    removeField.innerHTML = "&times; Remove";

    firstRow.appendChild(fileNameSpan);
    firstRow.appendChild(titleContainer);

    secondRow.appendChild(progressBarWrapper);
    secondRow.appendChild(tileInputContainer);
    secondRow.appendChild(removeField);

    wrapper.appendChild(firstRow);
    wrapper.appendChild(secondRow);

    this.container.appendChild(wrapper);

    return wrapper;
  }

  addSaveButtonEventListeners() {
    const saveButton =  document.querySelector(`.add-attachment-${this.name}`);
    saveButton.addEventListener("click", () => {
      Array.from(this.container.children).forEach((child) => {
        console.log("child.nodeName", child.nodeName);
        console.log("child.className", child.className);
        if (child.nodeName === "DIV" && child.className === `pending-${this.name}`) {
          console.log("document added");
          child.className = `active-${this.name}`;
          this.attachments.append(child);
        }
      })
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
}
