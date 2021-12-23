import { DirectUpload } from "@rails/activestorage";

export class Uploader {
  constructor(file, fileFields, options) {
    this.upload = new DirectUpload(file, options.url, options.token, options.attachmentName, this)
    this.fileFields = fileFields;
    this.progressBar = fileFields.querySelector(".progress-bar")
  }

  directUploadWillStoreFileWithXHR(request) {
    request.upload.addEventListener("progress", (event) => {
      const percentage = `${Math.floor(event.loaded / event.total) * 100}%`;
      this.progressBar.style.width = percentage;
      if (percentage === "100%") {
        this.progressBar.innerHTML = "Uploaded";
        this.progressBar.style.justifyContent = "center";
        return;
      }
      this.progressBar.innerHTML = percentage;
    });
  }
}
