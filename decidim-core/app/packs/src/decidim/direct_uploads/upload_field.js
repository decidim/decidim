import UploadModal from "src/decidim/direct_uploads/upload_modal";
import { truncateFilename, createHiddenInput } from "src/decidim/direct_uploads/upload_utility";

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
  um.saveButton.addEventListener("click", (event) => {
    event.preventDefault();
    const validatedItems = um.uploadItems.querySelectorAll(".upload-item[data-state='validated']")
    const validatedItemsCount = validatedItems.length;
    validatedItems.forEach((item) => {
      let details = item.querySelector(".attachment-details");
      if (details) {
        um.activeAttachments.appendChild(details);
      } else {
        details = um.activeAttachments.querySelector(`.attachment-details[data-filename='${item.dataset.filename}'`);
      }
      const span = details.querySelector("span");
      span.classList.add("filename");
      if (um.options.titled) {
        const title = item.querySelector("input[type='text']").value;
        details.dataset.title = title;
        let hiddenTitle = details.querySelector(".hidden-title")
        if (hiddenTitle) {
          hiddenTitle.value = title;
        } else {
          const attachmentId = details.querySelector(`[name='${um.options.resourceName}[${um.name}][]'`).value
          const ordinalNumber = um.getOrdinalNumber()
          const hiddenTitleField = createHiddenInput("hidden-title", `${um.options.resourceName}[${um.options.addAttribute}][${ordinalNumber}][title]`, title)
          const hiddenIdField = createHiddenInput("hidden-id", `${um.options.resourceName}[${um.options.addAttribute}][${ordinalNumber}][id]`, attachmentId)
          details.appendChild(hiddenTitleField);
          details.appendChild(hiddenIdField);
        }
        span.innerHTML = `${title} (${truncateFilename(item.dataset.filename)})`;
      } else {
        span.innerHTML = truncateFilename(item.dataset.filename, 19);
      }
      span.style.display = "block";
    });

    if (!um.options.titled && um.trashCan.children.length > 0) {
      um.activeAttachments.innerHTML = `<input name='${um.options.resourceName}[remove_${um.name}]' type="hidden" value="true">`;
    }

    if (validatedItemsCount > 0) {
      // Foundation helper does some magic with error fields, so these must be triggered using jQuery.
      const $el = $(um.uploadContainer.querySelector("input[type='checkbox']"));
      if ($el) {
        $el.prop("checked", true);
        $el.trigger("change");
      }
    }
    um.cleanTrashCan();
    um.updateAddAttachmentsButton();
  });
}

document.addEventListener("DOMContentLoaded", () => {
  const attachmentButtons = document.querySelectorAll("button.add-file");

  attachmentButtons.forEach((attachmentButton) => {
    const um = new UploadModal(attachmentButton);
    loadAttachments(um);
    addInputEventListener(um);
    addButtonEventListener(um);
    addDropZoneEventListeners(um);
    addSaveButtonEventListener(um);
  })
})
