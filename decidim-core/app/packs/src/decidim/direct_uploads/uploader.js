import { DirectUpload } from "@rails/activestorage";

export class Uploader {
  constructor(modal, uploadItem, options) {
    this.modal = modal;
    this.upload = new DirectUpload(options.file, options.url, options.token, options.file.name, this);
    this.uploadItem = uploadItem;
    this.progressBar = uploadItem.querySelector(".progress-bar");
    this.validationSent = false;
  }

  validate(blobId) {
    console.log("validate blobId", blobId);
    const callback = (data) => {
      console.log("data", data)
      let errors = []
      for (const [, value] of Object.entries(data)) {
        errors = errors.concat(value);
      }

      this.progressBar.style.justifyContent = "center";
      if (errors.length === 0) {
        this.progressBar.innerHTML = this.modal.locales.uploaded;
        this.uploadItem.dataset.state = "validated";
      } else {
        this.progressBar.innerHTML = this.modal.locales.validationError;
        this.uploadItem.dataset.state = "error";
        const errorList = this.uploadItem.querySelector(".upload-errors");
        this.uploadItem.appendChild(errorList);
        errors.forEach((error) => {
          const errorItem = document.createElement("li");
          errorItem.classList.add("form-error", "is-visible");
          errorItem.innerHTML = error;
          errorList.appendChild(errorItem);
        })
      }
    }

    if (!this.validationSent) {
      let attribute = this.modal.addAttribute;
      if (this.modal.titled) {
        attribute = "file"
      }

      const params = new URLSearchParams({
        resource: this.modal.resourceClass,
        attribute: attribute,
        blob: blobId
      });

      fetch(`/upload_validations?${params.toString()}`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": $("meta[name=csrf-token]").attr("content")
        }
      }).then((response) => response.json()).then((data) => {
        callback(data);
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
        this.progressBar.innerHTML = this.modal.locales.validating;
        return;
      }
      this.progressBar.innerHTML = `${progress}%`;
    });
  }
}
