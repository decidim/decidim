import TomSelect from "tom-select/dist/cjs/tom-select.popular";

document.addEventListener("DOMContentLoaded", () => {
  const selectors = {
    form: document.querySelector(".form.newsletter_deliver"),
    sendToAllUsers: document.querySelector("#newsletter_send_to_all_users"),
    sendToVerifiedUsers: document.querySelector("#newsletter_send_to_verified_users"),
    sendToParticipants: document.querySelector("#newsletter_send_to_participants"),
    sendToFollowers: document.querySelector("#newsletter_send_to_followers"),
    sendToPrivateMembers: document.querySelector("#newsletter_send_to_private_members"),
    verificationTypesSelect: document.querySelector("#verification_types_for_select"),
    participatorySpacesForSelect: document.querySelector("#participatory_spaces_for_select"),
    deliverButton: document.querySelector("#deliver-button"),
    confirmRecipientsLink: document.querySelector("#confirm-recipients-link"),
    recipientsCount: document.querySelector("#recipients_count"),
    recipientsCountSpinner: document.querySelector("#recipients_count_spinner"),
    csrfToken: document.querySelector('meta[name="csrf-token"]')
  };

  const inputs = {
    radioButtons: [selectors.sendToAllUsers, selectors.sendToVerifiedUsers].filter(Boolean),
    checkboxes: [
      selectors.sendToParticipants,
      selectors.sendToFollowers,
      selectors.sendToPrivateMembers
    ].filter(Boolean)
  };

  const toggleVisibility = (element, condition) => {
    if (element) {
      element.classList.toggle("hidden", !condition);
    }
  };

  const updateHiddenField = (input) => {
    const hiddenInput = selectors.form?.elements[input.name];
    if (hiddenInput) {
      hiddenInput.value = input.checked
        ? "1"
        : "0";
    }
  };

  const ensureAtLeastOneOptionSelected = () => {
    if (![...inputs.radioButtons, ...inputs.checkboxes].some((input) => input?.checked)) {
      selectors.sendToAllUsers.checked = true;
      updateHiddenField(selectors.sendToAllUsers);
    }
  };

  const updateConfirmRecipientsLink = () => {
    if (selectors.confirmRecipientsLink) {
      const params = new URLSearchParams(new FormData(selectors.form));
      selectors.confirmRecipientsLink.setAttribute(
        "href",
        `${selectors.confirmRecipientsLink.dataset.baseUrl}?${params.toString()}`
      );
    }
  };

  const updateRecipientsCount = async () => {
    const url = selectors.form?.dataset?.recipientsCountNewsletterPath;
    if (!url) {
      return;
    }

    selectors.recipientsCountSpinner?.classList.remove("hide");
    try {
      const response = await fetch(url, {
        method: "POST",
        headers: { "X-CSRF-Token": selectors.csrfToken?.content },
        body: new FormData(selectors.form)
      });
      selectors.recipientsCount.textContent = await response.text();
    } catch (error) {
      console.error("Error fetching recipients count:", error);
    } finally {
      selectors.recipientsCountSpinner?.classList.add("hide");
    }
  };

  const updateFormState = () => {
    [...inputs.radioButtons, ...inputs.checkboxes].forEach(updateHiddenField);
    const isAllUsersChecked = selectors.sendToAllUsers?.checked;
    const isAnyChecked = [...inputs.radioButtons, ...inputs.checkboxes].some((input) => input?.checked);

    selectors.deliverButton?.style.setProperty("display", isAllUsersChecked
      ? "inline-block"
      : "none");
    toggleVisibility(selectors.confirmRecipientsLink, !isAllUsersChecked && isAnyChecked);
    toggleVisibility(
      selectors.participatorySpacesForSelect,
      inputs.checkboxes.some((input) => input.checked) && !selectors.sendToVerifiedUsers?.checked
    );
    toggleVisibility(selectors.verificationTypesSelect, selectors.sendToVerifiedUsers?.checked);
    ensureAtLeastOneOptionSelected();
    updateConfirmRecipientsLink();
    updateRecipientsCount();
  };

  const attachEventListeners = () => {
    inputs.radioButtons.forEach((radio) =>
      radio.addEventListener("change", () => {
        inputs.radioButtons.forEach((rb) => (rb.checked = rb === radio));
        inputs.checkboxes.forEach((checkbox) => (checkbox.checked = false));
        updateFormState();
      })
    );

    inputs.checkboxes.forEach((checkbox) =>
      checkbox.addEventListener("change", () => {
        inputs.radioButtons.forEach((radio) => (radio.checked = false));
        updateFormState();
      })
    );

    selectors.form?.addEventListener("change", updateFormState);
  };

  const initializeTomSelect = () => {
    document.querySelectorAll("[data-multiselect='true']").forEach((container) =>
      new TomSelect(container, {
        plugins: ["remove_button", "dropdown_input"],
        allowEmptyOption: true
      })
    );

    document.
      querySelectorAll("#participatory_spaces_for_select select[data-multiselect='true']").
      forEach((selectTag) =>
        selectTag.addEventListener("change", () => {
          const selectedOptions = Array.from(selectTag.selectedOptions).map((option) => option.value);
          if (selectedOptions.includes("all")) {
            selectTag.querySelectorAll("option").forEach((option) => {
              option.selected = option.value !== "all";
            });
          }
        })
      );
  };

  updateFormState();
  attachEventListeners();
  initializeTomSelect();
});
