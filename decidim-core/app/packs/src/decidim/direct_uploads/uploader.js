import { DirectUpload } from "@rails/activestorage";

export class Uploader {
  constructor(file, uploadItem, options) {
    this.upload = new DirectUpload(file, options.url, options.token, options.attachmentName, this)
    console.log("this.upload", this.upload)
    this.uploadItem = uploadItem;
    this.progressBar = uploadItem.querySelector(".progress-bar")
    this.validationSent = false;
  }

  validate(blobId) {
    console.log("validate blobId", blobId);
    const callback = (data) => {
      console.log("data", data)
      this.progressBar.innerHTML = "uploaded";
      this.progressBar.style.justifyContent = "center";
      this.uploadItem.dataset.state = "uploaded";
    }

    if (!this.validationSent) {
      const params = new URLSearchParams({
        resource: "Decidim::User",
        attribute: "avatar",
        blob: blobId
      });

      fetch(`/upload_validations?${params.toString()}`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": $("meta[name=csrf-token]").attr("content")
        }
      }).then((response) => response.json()).then((data) => {
        callback(data)
      });
      this.validationSent = true;
    }
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
        return;
      }
      this.progressBar.innerHTML = `${progress}%`;
    });
  }
}
