import UploadModal from "src/decidim/direct_uploads/upload_modal";

const loadAttachments = (um) => {
  Array.from(um.activeAttachments.children).forEach((child) => {
    um.createUploadItem(child.dataset.filename, child.dataset.title, "validated");
  })
}

const addInputEventListener = (um) => {
  um.input.addEventListener("change", (event) => {
    event.preventDefault();
    const files = event.target.files;
    Array.from(files).forEach((file) => um.uploadFile(file));
  })
}

const addButtonEventListener = (um) => {
  um.button.addEventListener("click", (event) => {
    event.preventDefault();
    Array.from(um.trashCan.children).forEach((item) => {
      um.uploadItems.append(item);
    })
    if (um.uploadItems.children.length === 0) {
      um.modalTitle.innerHTML = um.modalTitle.dataset.addlabel;
    } else {
      um.modalTitle.innerHTML = um.modalTitle.dataset.editlabel;
    }
    um.updateDropZone();
  })
}

const addDropZoneEventListeners = (um) => {
  um.dropZone.addEventListener("dragenter", (event) => {
    event.preventDefault();
  })

  um.dropZone.addEventListener("dragover", (event) => {
    event.preventDefault();
    um.dropZone.classList.add("is-dragover");
  })

  um.dropZone.addEventListener("dragleave", () => {
    um.dropZone.classList.remove("is-dragover");
  })

  um.dropZone.addEventListener("drop", (event) => {
    event.preventDefault();
    const files = event.dataTransfer.files;
    Array.from(files).forEach((file) => um.uploadFile(file));
  })
}

const addSaveButtonEventListener = (um) => {
  const saveButton = um.modal.querySelector(`.add-attachment-${um.name}`);

  saveButton.addEventListener("click", (event) => {
    event.preventDefault();
    um.uploadItems.querySelectorAll(".upload-item[data-state='validated']").forEach((item) => {
      let details = item.querySelector(".attachment-details");
      if (details) {
        um.activeAttachments.appendChild(details);
      } else {
        details = um.activeAttachments.querySelector(`.attachment-details[data-filename='${item.dataset.filename}'`);
      }
      const span = details.querySelector("span");
      span.classList.add("filename")
      if (um.options.titled) {
        const title = item.querySelector("input[type='text']").value;
        details.dataset.title = title;
        span.innerHTML = `${title} (${item.dataset.filename})`;
      } else {
        span.innerHTML = item.dataset.filename
      }
      span.style.display = "block";
    });

    um.cleanTrashCan();
    um.updateAddAttachmentsButton();
  });
}

const addRemoveButtonEventListener = (um) => {
  if (um.options.titled || !um.options.optional) {
    return;
  }

  const removeButton = um.uploadContainer.querySelector("button.remove-attachment");

  if (um.activeAttachments.children.length === 0) {
    removeButton.parentElement.style.display = "none";
  }

  removeButton.addEventListener("click", (event) => {
    event.preventDefault();
    console.log("klik")

    removeButton.parentElement.style.display = "none";
    um.uploadItems.innerHTML = "";
    um.activeAttachments.innerHTML = `<input name='${um.options.resourceName}[remove_${um.name}]' type="hidden" value="true">`;
  })
}

document.addEventListener("DOMContentLoaded", () => {
  const attachmentButtons = document.querySelectorAll("button.add-attachment");

  attachmentButtons.forEach((attachmentButton) => {
    const um = new UploadModal(attachmentButton);
    loadAttachments(um);
    addInputEventListener(um);
    addButtonEventListener(um);
    addDropZoneEventListeners(um);
    addSaveButtonEventListener(um);
    addRemoveButtonEventListener(um);
  })
})
