import { DirectUpload } from "@rails/activestorage";

export class Uploader {
  constructor(modal, uploadItem, options) {
    this.modal = modal;
    this.uploadItem = uploadItem;
    this.progressBar = uploadItem.querySelector(".progress-bar");
    this.validationSent = false;
    this.fileTooBig = false;
    if (modal.options.maxFileSize && options.file.size > modal.options.maxFileSize) {
      this.fileTooBig = true;
      this.showError([modal.locales.file_size_too_large]);
    } else {
      this.upload = new DirectUpload(options.file, options.url, this);
    }
  }

  showError(errors) {
    this.progressBar.classList.add("filled");
    this.progressBar.innerHTML = this.modal.locales.validation_error;
    this.uploadItem.dataset.state = "error";
    const errorList = this.uploadItem.querySelector(".upload-errors");
    errors.forEach((error) => {
      const errorItem = document.createElement("li");
      errorItem.classList.add("form-error", "is-visible");
      errorItem.innerHTML = error;
      errorList.appendChild(errorItem);
    })
  }

  validate(blobId) {
    const callback = (data) => {
      let errors = []
      for (const [, value] of Object.entries(data)) {
        errors = errors.concat(value);
      }

      this.progressBar.style.justifyContent = "center";
      if (errors.length === 0) {
        this.progressBar.innerHTML = this.modal.locales.uploaded;
        this.uploadItem.dataset.state = "validated";
      } else {
        this.showError(errors);
      }
      this.progressBar.classList.add("filled");
    }

    if (!this.validationSent) {
      let property = this.modal.options.addAttribute;
      if (this.modal.options.titled) {
        property = "file"
      }
      const params = new URLSearchParams({
        resourceClass: this.modal.options.resourceClass,
        property: property,
        blob: blobId,
        formClass: this.modal.options.formObjectClass
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
      const progress = Math.floor(event.loaded / event.total * 100);
      let width = "15%";
      if (progress > 15) {
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
