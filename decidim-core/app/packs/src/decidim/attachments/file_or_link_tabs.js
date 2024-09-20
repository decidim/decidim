/**
 * This file controls the behavior of the |File| and |Link| tabs in the
 * attachment form. It disables the |File| tab when a link is present and
 * vice versa.
 */

const getFileButton = (container) =>
  container.querySelector("button#trigger-file");
const getLinkButton = (container) =>
  container.querySelector("button#trigger-link");
const getLinkInput = (container) =>
  container.querySelector("input#attachment_link");
const getUploadsContainer = (container) =>
  container.querySelector("div[data-active-uploads]");

const hasUploads = (container) => container.querySelectorAll("div").length > 0;

const updateTabsState = (container) => {
  const fileButton = getFileButton(container);
  const linkButton = getLinkButton(container);
  const linkInput = getLinkInput(container);
  const uploadsContainer = getUploadsContainer(container);

  const disableFileButton = Boolean(linkInput?.value);
  const disableLinkButton = hasUploads(uploadsContainer);

  fileButton.disabled = disableFileButton;
  linkButton.disabled = disableLinkButton;
};

const initializeTabs = (container) => {
  const linkInput = getLinkInput(container);
  const uploadsContainer = getUploadsContainer(container);

  linkInput.addEventListener("change", () => {
    updateTabsState(container);
  });

  const observer = new MutationObserver((mutationsList) => {
    mutationsList.forEach((mutation) => {
      if (mutation.type === "childList") {
        updateTabsState(container);
      }
    });
  });
  observer.observe(uploadsContainer, {childList: true, subtree: true});

  updateTabsState(container);
};

document.addEventListener("DOMContentLoaded", () => {
  const tabs = document.querySelectorAll(
    "div[data-file-or-link-tabs-controller]"
  );

  tabs.forEach((container) => {
    initializeTabs(container);
  });
});
