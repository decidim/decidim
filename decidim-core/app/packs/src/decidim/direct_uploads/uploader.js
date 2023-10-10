import { DirectUpload } from "@rails/activestorage";

export class Uploader {
  constructor(modal, options) {
    this.modal = modal;
    this.options = options;
    this.validationSent = false;
    this.errors = []

    if (modal.options.maxFileSize && options.file.size > modal.options.maxFileSize) {
      this.errors = [modal.locales.file_size_too_large]
    } else {
      this.upload = new DirectUpload(options.file, options.url, this);
    }
  }

  validate(blobId) {
    const callback = (data) => {
      let errors = []
      for (const [, value] of Object.entries(data)) {
        errors = errors.concat(value);
      }

      if (errors.length) {
        this.errors = errors;
      }
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

      return fetch(`/upload_validations?${params.toString()}`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": $("meta[name=csrf-token]").attr("content")
        }
      }).
        then((response) => response.json()).
        then((data) => {
          this.validationSent = true;
          callback(data);
        });
    }

    return Promise.resolve()
  }

  // The following method come from @rails/activestorage
  // {@link https://edgeguides.rubyonrails.org/active_storage_overview.html#direct-upload-javascript-events Active Storage Rails guide}
  directUploadWillStoreFileWithXHR(request) {
    request.upload.addEventListener("progress", ({ loaded, total }) => this.modal.setProgressBar(this.options.attachmentName, Math.floor(loaded / total * 100)));
  }
}
