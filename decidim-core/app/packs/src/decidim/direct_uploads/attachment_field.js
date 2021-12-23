import UploadModal from "src/decidim/direct_uploads/upload_modal";

document.addEventListener("DOMContentLoaded", () => {
  const attachmentButtons = document.querySelectorAll(".add-field.add-attachment");

  attachmentButtons.forEach((attachmentButton) => {
    console.log("attachmentButton", attachmentButton)
    const um = new UploadModal(attachmentButton);
    um.init();
  })
})
