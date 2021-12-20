import { DirectUpload } from "@rails/activestorage";

/* eslint-disable */
export class Uploader {
  constructor(file, el, options) {
    this.upload = new DirectUpload(file, options.url, options.token, options.attachmentName, this)
    this.options = options;
    this.el = el;
    this.container = this.el.closest(".dropzone-container");

    this.progressBarWrapper = document.createElement("div");
    this.progressBarWrapper.className = "progress-bar-wrapper";

    this.progressBar = document.createElement("div");
    this.progressBar.className = "progress-bar";

    this.container.appendChild(this.progressBarWrapper);
    this.progressBarWrapper.appendChild(this.progressBar);

    addEventListener("direct-upload:end", () => {
      this.progressBar.innerHTML = "100%"
      this.progressBar.style.width = "100%";
    })

    this.foo(file);
  }

  foo(file) {
    this.upload.create((error, blob) => {
      console.log("upload started");
      if (error) {
        console.error(error);
      } else {
        // Add an appropriately-named hidden input to the form with a
        //  value of blob.signed_id so that the blob ids will be
        //  transmitted in the normal upload flow
        console.log("file", file);
        const hiddenField = document.createElement("input");
        hiddenField.setAttribute("type", "hidden");
        hiddenField.setAttribute("value", blob.signed_id);
        hiddenField.name = this.el.name;
        this.container.appendChild(hiddenField);
      }
    });
  }

  directUploadWillStoreFileWithXHR(request) {
    request.upload.addEventListener("progress",
      event => this.directUploadDidProgress(event))
  }

  directUploadDidProgress(event) {
    // Use event.loaded and event.total to update the progress bar
    console.log("event.loaded", event.loaded);
    console.log("event.total", event.total);
    const percentage = `${Math.floor(event.loaded / event.total) * 100}%`;
    console.log("percentage", percentage);
    this.progressBar.innerHTML = percentage;
    this.progressBar.style.width = percentage;
  }
}

/* eslint-enable */
