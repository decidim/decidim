import TomSelect from "tom-select/dist/cjs/tom-select.popular";

document.addEventListener("DOMContentLoaded", () => {
  const isOnSelectRecipientsPage = window.location.pathname.includes("/select_recipients_to_deliver");

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

  const toggleVisibility = (element, condition) => element?.classList.toggle("hidden", !condition);

  const updateDeliverButtonVisibility = () => {
    const sendToAllUsersChecked = selectors.form?.elements["newsletter[send_to_all_users]"]?.value === "1";

    toggleVisibility(selectors.deliverButton, sendToAllUsersChecked);
    toggleVisibility(selectors.confirmRecipientsLink, !sendToAllUsersChecked);
  };

  const updateHiddenField = (input) => {
    const hiddenInput = selectors.form?.elements[input.name];
    if (hiddenInput) {
      hiddenInput.value = input.checked
        ? "1"
        : "0";}
  };

  const ensureAtLeastOneOptionSelected = () => {
    if (![...inputs.radioButtons, ...inputs.checkboxes].some((input) => input?.checked)) {
      selectors.sendToAllUsers.checked = true;
      updateHiddenField(selectors.sendToAllUsers);
    }
  };

  const updateConfirmRecipientsLink = () => {
    if (!selectors.confirmRecipientsLink) {
      return;
    }
    const params = new URLSearchParams(new FormData(selectors.form));
    selectors.confirmRecipientsLink.setAttribute(
      "href",
      `${selectors.confirmRecipientsLink.dataset.baseUrl}?${params.toString()}`
    );
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

  const resetIdsForParticipatorySpaces = () => {
    document.querySelectorAll('.form.newsletter_deliver select[name$="[ids][]"]').forEach((select) => {
      if (select.tomselect) {
        select.tomselect.clear();
      } else {
        select.value = [];
      }
    });
  };

  const resetVerificationTypes = () => {
    const select = document.querySelector("#verification-types-select");
    select?.tomselect?.clear();
    const hiddenInput = selectors.form?.elements["newsletter[verification_types]"];
    if (hiddenInput) {
      hiddenInput.value = "";
    }
  };

  const updateFormState = () => {
    [...inputs.radioButtons, ...inputs.checkboxes].forEach(updateHiddenField);
    const isAllUsersChecked = selectors.sendToAllUsers?.checked;
    const isAnyChecked = [...inputs.radioButtons, ...inputs.checkboxes].some((input) => input?.checked);

    toggleVisibility(selectors.deliverButton, isAllUsersChecked);
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

  const handleRadioChange = (radio) => {
    inputs.radioButtons.forEach((rb) => (rb.checked = rb === radio));
    inputs.checkboxes.forEach((checkbox) => (checkbox.checked = false));
    resetVerificationTypes();
    resetIdsForParticipatorySpaces();
    updateFormState();
  };

  const handleCheckboxChange = () => {
    inputs.radioButtons.forEach((radio) => (radio.checked = false));
    resetVerificationTypes();
    resetIdsForParticipatorySpaces();
    updateFormState();
  };

  const attachEventListeners = () => {
    inputs.radioButtons.forEach((radio) =>
      radio.addEventListener("change", () => handleRadioChange(radio))
    );

    inputs.checkboxes.forEach((checkbox) =>
      checkbox.addEventListener("change", handleCheckboxChange)
    );

    selectors.form?.addEventListener("change", updateFormState);
  };

  const initializeTomSelect = () => {
    document.querySelectorAll("[data-multiselect='true']").forEach((select) => {
      const tomSelect = new TomSelect(select, {
        plugins: ["remove_button", "dropdown_input"],
        allowEmptyOption: true
      });

      tomSelect.on("change", () => {
        const selectedOptions = tomSelect.getValue();

        if (selectedOptions.includes("all") && selectedOptions.length > 1) {
          tomSelect.setValue(["all"]);
        }
      });
    });
  };

  if (isOnSelectRecipientsPage) {
    attachEventListeners();
    initializeTomSelect();
    updateFormState();
    updateDeliverButtonVisibility();
  }
});
