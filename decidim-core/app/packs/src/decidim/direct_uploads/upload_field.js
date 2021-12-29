import UploadModal from "src/decidim/direct_uploads/upload_modal";

document.addEventListener("DOMContentLoaded", () => {
  const attachmentButtons = document.querySelectorAll("button.add-attachment");

  attachmentButtons.forEach((attachmentButton) => {
    const um = new UploadModal(attachmentButton);
    um.init();
  })
})
