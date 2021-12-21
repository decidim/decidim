import { DirectUpload } from "@rails/activestorage";

/* eslint-disable */
export class Uploader {
  constructor(file, fileFields, options) {
    this.upload = new DirectUpload(file, options.url, options.token, options.attachmentName, this)
    this.fileFields = fileFields;
    this.progressBar = fileFields.querySelector(".progress-bar")
  }

  directUploadWillStoreFileWithXHR(request) {
    request.upload.addEventListener("progress",
      event => this.directUploadDidProgress(event))
  }

  directUploadDidProgress(event) {
    // Use event.loaded and event.total to update the progress bar
    const percentage = `${Math.floor(event.loaded / event.total) * 100}%`;
    this.progressBar.innerHTML = percentage;
    this.progressBar.style.width = percentage;
  }
}

/* eslint-enable */
