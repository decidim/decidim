/* eslint-disable require-jsdoc */

export const timeKeyDownListener = (time) => {
  time.addEventListener("keydown", (event) => {
    switch (event.key) {
    case "ArrowUp":
      break;
    case "ArrowDown":
      break;
    case "ArrowLeft":
      break;
    case "ArrowRight":
      break;
    case "Backspace":
      break;
    case "Tab":
      break;
    case ":":
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
    if (time.value.length >= 5 && event.inputType === "insertText" && event.target.selectionStart === event.target.selectionEnd) {
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
      break;
    case "ArrowRight":
      break;
    case "Backspace":
      break;
    case "Tab":
      break;
    case "Delete":
      break;
    case ".":
      break;
    case "/":
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
    if (date.value.length >= 10 && event.inputType === "insertText" && event.target.selectionStart === event.target.selectionEnd) {
      event.preventDefault();
    };
  });
};
