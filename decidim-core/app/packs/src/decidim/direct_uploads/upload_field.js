import UploadModal from "src/decidim/direct_uploads/upload_modal";
import { truncateFilename, createHiddenInput } from "src/decidim/direct_uploads/upload_utility";

const loadAttachments = (modal) => {
  Array.from(modal.activeAttachments.children).forEach((child) => {
    modal.createUploadItem(child.dataset.filename, child.dataset.title, "validated");
  })
}

const addInputEventListener = (modal) => {
  modal.input.addEventListener("change", (event) => {
    event.preventDefault();
    const files = event.target.files;
    Array.from(files).forEach((file) => modal.uploadFile(file));
  })
}

const addButtonEventListener = (modal) => {
  modal.button.addEventListener("click", (event) => {
    event.preventDefault();
    Array.from(modal.trashCan.children).forEach((item) => {
      modal.uploadItems.append(item);
    })
    if (modal.uploadItems.children.length === 0) {
      modal.modalTitle.innerHTML = modal.modalTitle.dataset.addlabel;
    } else {
      modal.modalTitle.innerHTML = modal.modalTitle.dataset.editlabel;
    }
    modal.updateDropZone();
  })
}

const addDropZoneEventListeners = (modal) => {
  modal.dropZone.addEventListener("dragenter", (event) => {
    event.preventDefault();
  })

  modal.dropZone.addEventListener("dragover", (event) => {
    event.preventDefault();
    modal.dropZone.classList.add("is-dragover");
  })

  modal.dropZone.addEventListener("dragleave", () => {
    modal.dropZone.classList.remove("is-dragover");
  })

  modal.dropZone.addEventListener("drop", (event) => {
    event.preventDefault();
    const files = event.dataTransfer.files;
    Array.from(files).forEach((file) => modal.uploadFile(file));
  })
}

const addSaveButtonEventListener = (modal) => {
  modal.saveButton.addEventListener("click", (event) => {
    event.preventDefault();
    const validatedItems = modal.uploadItems.querySelectorAll(".upload-item[data-state='validated']")
    const validatedItemsCount = validatedItems.length;
    validatedItems.forEach((item) => {
      let details = item.querySelector(".attachment-details");
      if (details) {
        modal.activeAttachments.appendChild(details);
      } else {
        details = modal.activeAttachments.querySelector(`.attachment-details[data-filename='${item.dataset.filename}'`);
      }
      const span = details.querySelector("span");
      span.classList.add("filename");
      if (modal.options.titled) {
        const title = item.querySelector("input[type='text']").value;
        details.dataset.title = title;
        let hiddenTitle = details.querySelector(".hidden-title")
        if (hiddenTitle) {
          hiddenTitle.value = title;
        } else {
          const attachmentId = details.querySelector(`[name='${modal.options.resourceName}[${modal.name}][]'`).value
          const ordinalNumber = modal.getOrdinalNumber()
          const hiddenTitleField = createHiddenInput("hidden-title", `${modal.options.resourceName}[${modal.options.addAttribute}][${ordinalNumber}][title]`, title)
          const hiddenIdField = createHiddenInput("hidden-id", `${modal.options.resourceName}[${modal.options.addAttribute}][${ordinalNumber}][id]`, attachmentId)
          details.appendChild(hiddenTitleField);
          details.appendChild(hiddenIdField);
        }
        span.innerHTML = `${title} (${truncateFilename(item.dataset.filename)})`;
      } else {
        span.innerHTML = truncateFilename(item.dataset.filename, 19);
      }
      span.style.display = "block";
    });

    if (!modal.options.titled && modal.trashCan.children.length > 0) {
      modal.activeAttachments.innerHTML = `<input name='${modal.options.resourceName}[remove_${modal.name}]' type="hidden" value="true">`;
    }

    if (validatedItemsCount > 0) {
      // Foundation helper does some magic with error fields, so these must be triggered using jQuery.
      const $el = $(modal.uploadContainer.querySelector("input[type='checkbox']"));
      if ($el) {
        $el.prop("checked", true);
        $el.trigger("change");
      }
    }
    modal.cleanTrashCan();
    modal.updateAddAttachmentsButton();
  });
}

document.addEventListener("DOMContentLoaded", () => {
  const attachmentButtons = document.querySelectorAll("button.add-file");

  attachmentButtons.forEach((attachmentButton) => {
    const modal = new UploadModal(attachmentButton);
    loadAttachments(modal);
    addInputEventListener(modal);
    addButtonEventListener(modal);
    addDropZoneEventListeners(modal);
    addSaveButtonEventListener(modal);
  })
})
