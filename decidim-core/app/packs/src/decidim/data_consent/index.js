import ConsentManager from "./consent_manager";

const initDialog = (manager) => {
  if (Object.keys(manager.state).length > 0) {
    return;
  }

  const dialogWrapper = document.querySelector("#dc-dialog-wrapper");
  dialogWrapper.hidden = false

  const acceptAllButton = dialogWrapper.querySelector("#dc-dialog-accept");
  const rejectAllButton = dialogWrapper.querySelector("#dc-dialog-reject");
  const settingsButton = dialogWrapper.querySelector("#dc-dialog-settings");

  acceptAllButton.addEventListener("click", () => {
    manager.acceptAll();
    dialogWrapper.hidden = true;
  });

  rejectAllButton.addEventListener("click", () => {
    manager.rejectAll();
    dialogWrapper.hidden = true;
  });

  settingsButton.addEventListener("click", () => {
    dialogWrapper.hidden = true;
  });
}

const initModal = (manager) => {
  const acceptAllButton = manager.modal.querySelector("#dc-modal-accept");
  const rejectAllButton = manager.modal.querySelector("#dc-modal-reject");
  const saveSettingsButton = manager.modal.querySelector("#dc-modal-save");

  acceptAllButton.addEventListener("click", () => {
    manager.acceptAll();
  })

  rejectAllButton.addEventListener("click", () => {
    manager.rejectAll();
  })

  saveSettingsButton.addEventListener("click", () => {
    let newState = {};
    manager.categories.forEach((category) => {
      const accepted = manager.modal.querySelector(`input[name='${category}']`).checked;
      if (accepted) {
        newState[category] = true;
      }
    })
    manager.saveSettings(newState);
  })
}

const initDisabledIframes = (manager) => {
  const disabledIframes = document.querySelectorAll(".disabled-iframe")
  if (manager.allAccepted()) {
    disabledIframes.forEach((elem) => {
      const iframe = document.createElement("iframe")
      iframe.setAttribute("src", elem.getAttribute("src"));
      iframe.className = elem.classList.toString();
      iframe.setAttribute("allowfullscreen", elem.getAttribute("allowfullscreen"));
      iframe.setAttribute("frameborder", elem.getAttribute("frameborder"));
      elem.parentElement.appendChild(iframe);
      elem.remove();
    })
  }
}

document.addEventListener("DOMContentLoaded", () => {
  const modal = document.querySelector("#dc-modal");
  if (!modal) {
    return;
  }

  const categories = [...modal.querySelectorAll("[data-id]")].map((el) => el.dataset.id)
  const manager = new ConsentManager({
    modal: modal,
    categories: categories,
    cookieName: window.Decidim.config.get("consent_cookie_name"),
    warningElement: document.querySelector(".dataconsent-warning")
  });

  initDisabledIframes(manager);
  initModal(manager, categories);
  initDialog(manager);
});
