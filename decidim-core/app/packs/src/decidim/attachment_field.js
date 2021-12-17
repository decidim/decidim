import { DirectUpload } from "@rails/activestorage"


document.addEventListener("DOMContentLoaded", () => {
  const attachmentButtons = document.querySelectorAll(".add-field.add-attachment");

  attachmentButtons.forEach((attachmentButton) => {
    console.log("attachmentButton", attachmentButton)
    attachmentButton.addEventListener("click", (event) => {
      event.preventDefault();
      const el = document.querySelector(".reveal.attachment-modal")
      $(el).foundation("open");
    })
  })

  const dropZoneContainer = document.querySelector(".dropzone-container");
  const dropZone = document.querySelector("label.dropzone");

  dropZone.addEventListener("dragenter", (event) => {
    event.preventDefault();
  })

  dropZone.addEventListener("dragover", (event) => {
    event.preventDefault();
    dropZone.classList.add("is-dragover");
  })

  dropZone.addEventListener("dragleave", () => {
    dropZone.classList.remove("is-dragover");
  })

  const input = dropZone.querySelector("input");
  const uploadFile = (file) => {
    // your form needs the file_field direct_upload: true, which
    //  provides data-direct-upload-url, data-direct-upload-token
    // and data-direct-upload-attachment-name
    const url = input.dataset.directUploadUrl;
    const token = input.dataset.directUploadToken;
    const attachmentName = input.dataset.directUploadAttachmentName;
    const upload = new DirectUpload(file, url, token, attachmentName);

    upload.create((error, blob) => {
      if (error) {
        console.error(error);
      } else {
        // Add an appropriately-named hidden input to the form with a
        //  value of blob.signed_id so that the blob ids will be
        //  transmitted in the normal upload flow
        const hiddenField = document.createElement("input");
        hiddenField.setAttribute("type", "hidden");
        hiddenField.setAttribute("value", blob.signed_id);
        hiddenField.name = input.name;
        dropZoneContainer.appendChild(hiddenField);
      }
    })
  }

  dropZone.addEventListener("drop", (event) => {
    event.preventDefault();
    const files = event.dataTransfer.files;
    Array.from(files).forEach((file) => uploadFile(file));
  })
})
