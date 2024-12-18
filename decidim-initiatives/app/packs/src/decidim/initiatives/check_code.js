const validateCode = (path, code) => {
  return fetch(path, {
    method: "PUT",
    cache: "no-cache",
    headers: {
      "Content-Type": "application/json",
      "X-CSRF-Token": document.querySelector("meta[name=csrf-token]")?.content
    },
    body: JSON.stringify({ confirmation: { "verification_code": code } })
  }).
    then((response) => response.json()).
    then((json) => { return json.sms_code === "OK" });
};

const updateSubmit = (enable, includeAnnouncement) => {
  const correctAnnouncement = document.querySelector(".code-correct-announcement");
  const wrongAnnouncement = document.querySelector(".code-wrong-announcement");
  const submitButton = document.querySelector("[data-submit-verification-code]");

  if (enable) {
    if (includeAnnouncement) {
      correctAnnouncement.classList.remove("hidden");
    } else {
      correctAnnouncement.classList.add("hidden");
    }
    wrongAnnouncement.classList.add("hidden");
    submitButton.disabled = false;
  } else {
    correctAnnouncement.classList.add("hidden");
    if (includeAnnouncement) {
      wrongAnnouncement.classList.remove("hidden");
    } else {
      wrongAnnouncement.classList.add("hidden");
    }
    submitButton.disabled = true;
  }
}

const updateValue = (codeInput, event, digitsInputs) => {
  const checkCodePath = codeInput.dataset.checkCodePath;
  const index = Number(event.target.dataset.verificationCode);
  const prevDigit = digitsInputs[index - 1];
  const nextDigit = digitsInputs[index + 1];
  let digits = codeInput.value.split("");
  const newDigit = event.target.value || "-";
  if (newDigit.length > 0) {
    const position = event.target.dataset.verificationCode;
    digits[position] = newDigit;
    const newCode = digits.join("")
    if (codeInput.value !== newCode) {
      codeInput.value = newCode;
      if ((/^\d{6}$/).test(newCode)) {
        validateCode(checkCodePath, newCode).then((validCode) => updateSubmit(validCode, true));
      } else {
        updateSubmit(false, false);
      }
    }

    if (prevDigit && newDigit === "-") {
      prevDigit.focus();
    } else if (nextDigit && newDigit !== "-") {
      nextDigit.focus();
    }
  }
};

const initializeCodeVerificator = (codeElement) => {
  const codeInput = codeElement.querySelector("[data-check-code-path]");
  const digitsInputs = codeElement.querySelectorAll("[data-verification-code]");

  digitsInputs.forEach((digitInput) => {
    digitInput.addEventListener("input", (event) => updateValue(codeInput, event, digitsInputs));
  });
  codeInput.value = "------";
};

$(() => {
  const codeElement = document.querySelector("[data-check-code]");
  if (codeElement) {
    initializeCodeVerificator(codeElement);
  }
});
