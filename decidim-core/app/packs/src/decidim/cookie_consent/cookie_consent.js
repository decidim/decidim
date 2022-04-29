import ConsentManager from "src/decidim/cookie_consent/consent_manager";

const initDialog = (manager) => {
  if (manager.state) {
    return;
  }
  const dialogWrapper = document.querySelector("#cc-dialog-wrapper");
  dialogWrapper.classList.remove("hide");

  const acceptAllButton = dialogWrapper.querySelector("#cc-dialog-accept");
  const rejectAllButton = dialogWrapper.querySelector("#cc-dialog-reject");
  const settingsButton = dialogWrapper.querySelector("#cc-dialog-settings");

  acceptAllButton.addEventListener("click", () => {
    manager.acceptAll();
    dialogWrapper.style.display = "none";
  });

  rejectAllButton.addEventListener("click", () => {
    manager.rejectAll();
    dialogWrapper.style.display = "none";
  });

  settingsButton.addEventListener("click", () => {
    dialogWrapper.style.display = "none";
  });
}

const initModal = (manager) => {
  const categoryElements = manager.modal.querySelectorAll(".category-wrapper");
  manager.updateModalSelections(manager.state);

  categoryElements.forEach((categoryEl) => {
    const categoryButton = categoryEl.querySelector(".cc-title");
    const categoryDescription = categoryEl.querySelector(".cc-description");
    categoryButton.addEventListener("click", () => {
      const hidden = categoryDescription.classList.contains("hide");
      if (hidden) {
        categoryButton.classList.add("open");
        categoryDescription.classList.remove("hide");
      } else {
        categoryButton.classList.remove("open");
        categoryDescription.classList.add("hide");
      }
    })
  })

  const acceptAllButton = manager.modal.querySelector("#cc-modal-accept");
  const rejectAllButton = manager.modal.querySelector("#cc-modal-reject");
  const saveSettingsButton = manager.modal.querySelector("#cc-modal-save");

  acceptAllButton.addEventListener("click", () => {
    manager.acceptAll();
  })

  rejectAllButton.addEventListener("click", () => {
    manager.rejectAll();
  })

  saveSettingsButton.addEventListener("click", () => {
    let categoryHash = {};
    manager.categories.forEach((category) => {
      const accepted = manager.modal.querySelector(`input[name='${category}']`).checked;
      if (accepted) {
        categoryHash[category] = true;
      }
    })
    manager.saveSettings(categoryHash);
  })
}

document.addEventListener("DOMContentLoaded", () => {
  const modal = document.querySelector("#cc-modal");
  const categories = ["cc-essential", "cc-preferences", "cc-analytics", "cc-marketing"]
  const manager = new ConsentManager({
    modal: modal,
    categories: categories,
    cookieName: "decidim-cookie"
  });

  initModal(manager, categories);
  initDialog(manager);
});
