import { Uploader } from "src/decidim/direct_uploads/uploader";

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

  // const dropZoneContainer = document.querySelector(".dropzone-container");
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
    const uploader = new Uploader(file, input, {
      url: input.dataset.directuploadurl,
      token: "abcd1234",
      attachmentName: "test.pdf"
    });
    return uploader;
  }

  dropZone.addEventListener("drop", (event) => {
    event.preventDefault();
    const files = event.dataTransfer.files;
    Array.from(files).forEach((file) => uploadFile(file));
  })
})
/* eslint-enable */
