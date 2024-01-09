import data from "@emoji-mart/data"
import i18nEn from "@emoji-mart/data/i18n/en.json"
import { Picker } from "emoji-mart"

import * as i18n from "src/decidim/i18n";
import { screens } from "tailwindcss/defaultTheme"

class EmojiI18n {
  static isObject(item) {
    return (item && typeof item === "object" && !Array.isArray(item));
  }
  static deepMerge(target, ...sources) {
    if (!sources.length) {
      return target;
    }
    const source = sources.shift();

    if (this.isObject(target) && this.isObject(source)) {
      for (const key in source) {
        if (this.isObject(source[key])) {
          if (!target[key]) {
            Object.assign(target, { [key]: {} });
          }
          this.deepMerge(target[key], source[key]);
        } else {
          Object.assign(target, { [key]: source[key] });
        }
      }
    }

    return this.deepMerge(target, ...sources);
  }

  static locale() {
    return document.documentElement.getAttribute("lang");
  }

  static i18n() {
    return this.deepMerge(i18nEn, i18n.getMessages("emojis"));
  }
}
class EmojiPopUp {

  constructor(pickerOptions, handlerElement) {
    this.popUp = this.createContainer();
    this.popUp.appendChild(this.createCloseButton());
    this.popUp.appendChild(this.addStyles());

    let container = document.createElement("div");

    this.picker = new Picker({
      parent: container,
      i18n: EmojiI18n.i18n(),
      locale: EmojiI18n.locale(),
      data: data,
      perLine: 8,
      theme: "light",
      emojiButtonSize: 41,
      emojiSize: 30,
      ...(window.matchMedia(`(max-width: ${screens.sm})`).matches && { emojiButtonSize: 36 }),
      ...(window.matchMedia(`(max-width: ${screens.sm})`).matches && { emojiSize: 30 }),
      ...pickerOptions
    });

    this.popUp.appendChild(container);

    this.setCoordinates(handlerElement);
  }

  createCloseButton() {
    let closeButton = document.createElement("button");
    closeButton.type = "button";
    closeButton.classList.add("emoji-picker__closeButton");
    closeButton.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 320 512"><!--! Font Awesome Pro 6.1.1 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license (Commercial License) Copyright 2022 Fonticons, Inc. --><path d="M310.6 361.4c12.5 12.5 12.5 32.75 0 45.25C304.4 412.9 296.2 416 288 416s-16.38-3.125-22.62-9.375L160 301.3L54.63 406.6C48.38 412.9 40.19 416 32 416S15.63 412.9 9.375 406.6c-12.5-12.5-12.5-32.75 0-45.25l105.4-105.4L9.375 150.6c-12.5-12.5-12.5-32.75 0-45.25s32.75-12.5 45.25 0L160 210.8l105.4-105.4c12.5-12.5 32.75-12.5 45.25 0s12.5 32.75 0 45.25l-105.4 105.4L310.6 361.4z"/></svg>';
    closeButton.addEventListener("click", () => {
      this.close();
    });
    return closeButton;
  }

  addStyles() {
    let style = document.createElement("style");
    style.innerHTML = `
    em-emoji-picker {
    --color-border: rgb(204, 204, 204);
    --rgb-background: 249, 250, 251;
    --rgb-color: 0,0,0;
    --rgb-accent: var(--primary-rgb);
    --shadow: 5px 5px 15px -8px rgba(0,0,0,0.75);
    --color-border-over: rgba(0, 0, 0, 0.1);
    --rgb-input: 235, 235, 235;
    --background-rgb: var(--primary-rgb);
    --category-icon-size: 24px;

    border: 1px solid var(--color-border);
  }
  `;

    return style;
  }

  createContainer() {
    const container = document.createElement("div");

    container.classList.add("emoji-picker__popupContainer");
    container.classList.add("emoji__decidim");
    container.id = "picker"

    container.style.position = "absolute";
    container.style.zIndex = "1000";

    document.body.appendChild(container);

    return container;
  }

  setCoordinates(handlerElement) {
    let rect = handlerElement.getBoundingClientRect();

    let leftPosition = window.scrollX + rect.x;
    let topPosition = window.scrollY + rect.y;

    topPosition -= this.popUp.offsetHeight;
    leftPosition -= this.popUp.offsetWidth;

    let popUpWidth = window.matchMedia(`(max-width: ${screens.sm})`).matches
      ? 41 * 9
      : 36 * 8;
    // Emoji picker min-width of 352px set in styles.scss in emoji-mart
    leftPosition -= popUpWidth;

    if (leftPosition < 0) {
      leftPosition = parseInt((window.screen.availWidth - popUpWidth) / 2, 10) + 30;
    }

    this.popUp.style.top = `${topPosition}px`;
    this.popUp.style.left = `${leftPosition}px`;
  }

  close() {
    this.popUp.remove();
  }
}

export class EmojiButton {

  constructor(elem) {
    const wrapper = document.createElement("span");
    wrapper.className = "emoji__container"
    const btnContainer = document.createElement("span");
    btnContainer.className = "emoji__trigger"
    const btn = document.createElement("button");
    btn.className = "emoji__button"
    btn.type = "button"
    btn.setAttribute("aria-label", EmojiI18n.i18n().button)
    btn.innerHTML = '<svg aria-hidden="true" focusable="false" data-prefix="far" data-icon="smile" role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 496 512"><path fill="currentColor" d="M248 8C111 8 0 119 0 256s111 248 248 248 248-111 248-248S385 8 248 8zm0 448c-110.3 0-200-89.7-200-200S137.7 56 248 56s200 89.7 200 200-89.7 200-200 200zm-80-216c17.7 0 32-14.3 32-32s-14.3-32-32-32-32 14.3-32 32 14.3 32 32 32zm160 0c17.7 0 32-14.3 32-32s-14.3-32-32-32-32 14.3-32 32 14.3 32 32 32zm4 72.6c-20.8 25-51.5 39.4-84 39.4s-63.2-14.3-84-39.4c-8.5-10.2-23.7-11.5-33.8-3.1-10.2 8.5-11.5 23.6-3.1 33.8 30 36 74.1 56.6 120.9 56.6s90.9-20.6 120.9-56.6c8.5-10.2 7.1-25.3-3.1-33.8-10.1-8.4-25.3-7.1-33.8 3.1z"></path></svg>'
    const referenceElement = document.createElement("span");
    referenceElement.className = "emoji__reference";

    const parent = elem.parentNode;
    parent.insertBefore(wrapper, elem);
    wrapper.appendChild(elem);
    wrapper.appendChild(btnContainer);
    wrapper.appendChild(referenceElement);
    btnContainer.appendChild(btn);

    // The form errors need to be in the same container with the field they
    // belong to for Foundation Abide to show them automatically.
    parent.querySelectorAll(".form-error").forEach((el) => wrapper.appendChild(el));

    let emojiSelectHandler = (emojidata) => {
      let emoji = emojidata.native;
      if (elem.contentEditable === "true") {
        if (elem.editor) {
          elem.editor.chain().insertContent(` ${emoji} `).focus().run();
        } else {
          elem.innerHTML += ` ${emoji} `
        }
      } else {
        elem.value += ` ${emoji} `
      }

      // Make sure the input event is dispatched on the input/textarea elements
      if (elem.tagName === "TEXTAREA" || elem.tagName === "INPUT") {
        elem.dispatchEvent(new Event("input"));
      }

      const event = new Event("emoji.added");
      elem.dispatchEvent(event);
    }

    let handlerPicker = () => {
      let popUp = document.getElementById("picker");
      if (popUp) {
        // We close the picker
        popUp.remove();
        return;
      }

      let pickerOptions = {
        onEmojiSelect: (emoji) => emojiSelectHandler(emoji),
        onClickOutside: (event) => {
          if (event.target.parentNode === btn) {
            return;
          }
          handlerPicker();
        }
      }

      // eslint-disable-next-line no-new
      new EmojiPopUp(pickerOptions, btn);
    }

    btn.addEventListener("click", handlerPicker);

    elem.addEventListener("emoji.added", handlerPicker);

    elem.addEventListener("characterCounter", (event) => {
      if (event.detail.remaining >= 4) {
        btn.addEventListener("click", handlerPicker);
        btn.removeAttribute("style");
      } else {
        btn.removeEventListener("click", handlerPicker);
        btn.setAttribute("style", "color:lightgrey");
      }
    });
  }
}

/**
 * Adds the input emojis to the input elements that are defined to have them.
 *
 * @param {HTMLElement} element target node
 * @returns {void}
 */
export default function addInputEmoji(element = document) {
  const containers = element.querySelectorAll("[data-input-emoji]");

  if (containers.length) {
    containers.forEach((elem) => new EmojiButton(elem))
  }
};
