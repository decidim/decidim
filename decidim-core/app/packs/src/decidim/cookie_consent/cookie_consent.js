import ConsentManager from "src/decidim/cookie_consent/consent_manager";

const initDialog = (manager) => {
  console.log("manager.state", manager.state);
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
  })

  rejectAllButton.addEventListener("click", () => {
    manager.rejectAll();
    dialogWrapper.style.display = "none";
  })

  settingsButton.addEventListener("click", () => {
    dialogWrapper.style.display = "none";
  })
}

const initModal = (manager, categories) => {
  const modal = document.querySelector("#cc-modal");
  const categoryElements = modal.querySelectorAll(".category-wrapper")

  categoryElements.forEach((categoryEl) => {
    const categoryInput = categoryEl.querySelector("input");

    if (manager.state && manager.state[categoryInput.name]) {
      categoryInput.checked = true;
    } else if (!categoryInput.disabled) {
      categoryInput.checked = false;
    }

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

  const acceptAllButton = modal.querySelector("#cc-modal-accept");
  const rejectAllButton = modal.querySelector("#cc-modal-reject");
  const saveSettingsButton = modal.querySelector("#cc-modal-save");

  acceptAllButton.addEventListener("click", () => {
    manager.acceptAll();
  })

  rejectAllButton.addEventListener("click", () => {
    manager.rejectAll();
  })

  saveSettingsButton.addEventListener("click", () => {
    let categoryHash = {};
    categories.forEach((category) => {
      const accepted = modal.querySelector(`input[name='${category}']`).checked;
      if (accepted) {
        categoryHash[category] = true;
      }
    })
    manager.saveSettings(categoryHash);
  })
}

document.addEventListener("DOMContentLoaded", () => {
  const categories = ["essential", "preferences", "analytics", "marketing"]
  const manager = new ConsentManager({
    categories: categories
  });

  initModal(manager, categories);
  initDialog(manager);
});
