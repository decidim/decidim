import { DirectUpload } from "@rails/activestorage";

export class Uploader {
  constructor(file, uploadItem, options) {
    this.upload = new DirectUpload(file, options.url, options.token, options.attachmentName, this)
    this.uploadItem = uploadItem;
    this.progressBar = uploadItem.querySelector(".progress-bar")
  }

  directUploadWillStoreFileWithXHR(request) {
    request.upload.addEventListener("progress", (event) => {
      const progress = Math.floor(event.loaded / event.total) * 100;
      let width = "25%";
      if (progress > 25) {
        width = `${progress}%`;
      }
      this.progressBar.style.width = width;

      if (progress === 100) {
        this.progressBar.innerHTML = "uploaded";
        this.progressBar.style.justifyContent = "center";
        this.uploadItem.dataset.state = "uploaded";
        return;
      }
      this.progressBar.innerHTML = `${progress}%`;
    });
  }
}
