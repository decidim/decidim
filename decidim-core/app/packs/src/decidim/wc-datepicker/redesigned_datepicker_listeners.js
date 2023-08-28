/* eslint-disable require-jsdoc */

export const timeKeyDownListener = (time) => {
  time.addEventListener("keydown", (event) => {
    switch (event.key) {
    case "ArrowUp":
      break;
    case "ArrowDown":
      break;
    case "ArrowLeft":
      if (time.value.length > 2 && event.target.selectionStart < 4) {
        event.preventDefault();
      }
      break;
    case "ArrowRight":
      break;
    case "Backspace":
      if (event.target.selectionStart === 0 && event.target.selectionEnd === time.value.length) {
        break;
      } else if (time.value.length > 3 && event.target.selectionStart < 4) {
        event.preventDefault();
      };

      break;
    case "Tab":
      break;
    default:
      if ((/[0-9]/).test(event.key)) {
        break;
      } else if (event.ctrlKey === true || event.altKey === true) {
        break;
      } else {
        event.preventDefault();
      };
    };
  });
};
export const timeBeforeInputListener = (time) => {
  time.addEventListener("beforeinput", (event) => {
    if (time.value.length === 2 && event.inputType === "insertText") {
      time.value += ":";
    };

    if (time.value.length >= 5 && event.inputType === "insertText") {
      event.preventDefault();
    };
  });
};

export const dateKeyDownListener = (date) => {
  date.addEventListener("keydown", (event) => {
    switch (event.key) {
    case "ArrowUp":
      break;
    case "ArrowDown":
      break;
    case "ArrowLeft":
      if (date.value.length > 2 && event.target.selectionStart < 4 || date.value.length > 5 && event.target.selectionStart < 7) {
        event.preventDefault();
      };

      break;
    case "ArrowRight":
      break;
    case "Backspace":
      if (event.target.selectionStart === 0 && event.target.selectionEnd === date.value.length) {
        break;
      } else if (date.value.length > 3 && event.target.selectionStart < 4 || date.value.length > 6 && event.target.selectionStart < 7) {
        event.preventDefault();
      };

      break;
    case "Tab":
      break;
    default:
      if ((/[0-9]/).test(event.key)) {
        break;
      } else if (event.ctrlKey === true || event.altKey === true) {
        break;
      } else {
        event.preventDefault();
      };
    };
  });
};

export const dateBeforeInputListener = (date) => {
  date.addEventListener("beforeinput", (event) => {
    if ((date.value.length === 2 || date.value.length === 5) && event.inputType === "insertText") {
      date.value += "/";
    };

    if (date.value.length >= 10 && event.inputType === "insertText") {
      event.preventDefault();
    };
  });
};

export const datePasteListener = (date) => {
  date.addEventListener("paste", (event) => {
    event.preventDefault();
    const value = event.clipboardData.getData("text/plain");

    if ((/^([0-9]|0[0-9]|1[0-9]|2[0-9]|3[0-1])(-|\/)([0-9]|0[0-9]|1[0-9]|2[0-9]|3[0-1])(-|\/)([0-9]{4})$/).test(value)) {
      if ((/(^[0-9])(-|\/)([0-9])(-|\/)([0-9]{4})$/).test(value)) {
        date.value = `0${value[0]}/0${value[2]}/${value.substring(value.length - 4)}`
      } else {
        date.value = value.replaceAll("-", "/");
      };
    };
  });
};
