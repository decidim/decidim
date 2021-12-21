import { Uploader } from "src/decidim/direct_uploads/uploader";

export default class UploadModal {
  constructor(button, options = {}) {
    this.button = button;
    this.name = this.button.name;
    this.container = document.querySelector(`div[data-name='${this.name}']`)
    this.dropZone = this.container.querySelector(".dropzone");
    this.input = this.container.querySelector("input");
  }

  init() {
    this.addDropzoneEventListeners();
  }

  uploadFile(file) {
    console.log("file", file);
    const fileFields = this.createFileFields(file)
    const uploader = new Uploader(file, fileFields, {
      url: this.input.dataset.directuploadurl,
      token: "abcd1234",
      attachmentName: file.name
    });

    uploader.upload.create((error, blob) => {
      console.log("upload started");
      if (error) {
        console.error(error);
      } else {
        // Add an appropriately-named hidden input to the form with a
        //  value of blob.signed_id so that the blob ids will be
        //  transmitted in the normal upload flow
        const hiddenField = document.createElement("input");
        hiddenField.setAttribute("type", "hidden");
        hiddenField.setAttribute("value", blob.signed_id);
        hiddenField.name = this.input.name;
        this.container.appendChild(hiddenField);
      }
    });
  }

  createFileFields(file) {
    const wrapper = document.createElement("div");
    wrapper.className = "file-fields";

    const firstRow = document.createElement("div");
    firstRow.classList.add("row");
    const secondRow = document.createElement("div");
    secondRow.classList.add("row");

    const fileName = document.createElement("span");
    fileName.classList.add("columns", "small-4");
    fileName.innerHTML = file.name

    const title = document.createElement("span");
    title.innerHTML = "Title";

    const titleContainer = document.createElement("div");
    titleContainer.classList.add("columns", "small-8");
    titleContainer.appendChild(title);

    const progressBar = document.createElement("div");
    progressBar.classList.add("progress-bar");

    const progressBarBorder = document.createElement("div");
    progressBarBorder.classList.add("progress-bar-border");
    progressBarBorder.appendChild(progressBar);

    const progressBarWrapper = document.createElement("div");
    progressBarWrapper.classList.add("columns", "small-4");
    progressBarWrapper.appendChild(progressBarBorder);

    const titleInput = document.createElement("input");
    titleInput.type = "text";
    titleInput.value = file.name.split(".")[0];

    const tileInputContainer = document.createElement("div");
    tileInputContainer.classList.add("columns", "small-5");
    tileInputContainer.appendChild(titleInput);

    const removeField = document.createElement("span");
    removeField.classList.add("columns", "small-3");
    removeField.innerHTML = "&times; Remove";

    firstRow.appendChild(fileName);
    firstRow.appendChild(titleContainer);

    secondRow.appendChild(progressBarWrapper);
    secondRow.appendChild(tileInputContainer);
    secondRow.appendChild(removeField);

    wrapper.appendChild(firstRow);
    wrapper.appendChild(secondRow);

    this.container.appendChild(wrapper);

    return wrapper;
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
