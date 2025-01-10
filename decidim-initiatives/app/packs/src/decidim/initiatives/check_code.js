const focusDigit = (digit) => {
  const length = digit.value.length;
  digit.focus();
  setTimeout(() => digit.setSelectionRange(length, length), 0);
};

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
  const incorrectAnnouncement = document.querySelector(".code-incorrect-announcement");
  const submitButton = document.querySelector("[data-submit-verification-code]");
  const resendCodeMessage = document.querySelector("[data-resend-code]");

  if (enable) {
    if (includeAnnouncement) {
      correctAnnouncement.classList.remove("hidden");
      resendCodeMessage.classList.add("hidden");
    } else {
      correctAnnouncement.classList.add("hidden");
      resendCodeMessage.classList.remove("hidden");
    }
    incorrectAnnouncement.classList.add("hidden");
    submitButton.classList.remove("hidden");
    submitButton.disabled = false;
  } else {
    if (includeAnnouncement) {
      incorrectAnnouncement.classList.remove("hidden");
      resendCodeMessage.classList.add("hidden");
    } else {
      incorrectAnnouncement.classList.add("hidden");
      resendCodeMessage.classList.remove("hidden");
    }
    correctAnnouncement.classList.add("hidden");
    submitButton.classList.add("hidden");
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
      focusDigit(prevDigit);
    } else if (nextDigit && newDigit !== "-") {
      focusDigit(nextDigit);
    }
  }
};

const updatePosition = (codeInput, event, digitsInputs) => {
  const index = Number(event.target.dataset.verificationCode);
  const nextDigit = (() => {
    if (event.key === "ArrowLeft" || ["Delete", "Backspace"].includes(event.key) && event.target.value === "") {
      return digitsInputs[index - 1];
    } else if (event.key === "ArrowRight" || (/^\d$/).test(event.key) && event.target.value.length > 0) {
      return digitsInputs[index + 1];
    }
    return false;
  })();

  if (nextDigit) {
    focusDigit(nextDigit);
  }
  return true;
};


const initializeCodeVerificator = (codeElement) => {
  const codeInput = codeElement.querySelector("[data-check-code-path]");
  const digitsInputs = codeElement.querySelectorAll("[data-verification-code]");

  digitsInputs.forEach((digitInput) => {
    digitInput.addEventListener("input", (event) => updateValue(codeInput, event, digitsInputs));
    digitInput.addEventListener("keydown", (event) => updatePosition(codeInput, event, digitsInputs));
  });
  codeInput.value = "------";
};

$(() => {
  const codeElement = document.querySelector("[data-check-code]");
  if (codeElement) {
    initializeCodeVerificator(codeElement);
  }
});
