import { createPopup } from "@picmo/popup-picker";
import { screens } from "tailwindcss/defaultTheme"
import { SUPPORTED_LOCALES } from "emojibase";

import * as i18n from "src/decidim/i18n";

let I18N_CONFIG = null;

export class EmojiButton {
  static i18n() {
    if (I18N_CONFIG) {
      return I18N_CONFIG;
    }

    let dict = i18n.getMessages("emojis") || null;
    const buttonText = dict.button;
    if (dict) {
      Reflect.deleteProperty(dict, "button");
      dict = i18n.createDictionary(dict);
    }

    // dictionary = the messages dictionary passed to Picmo
    // messages = local "extra" messages
    I18N_CONFIG = {
      dictionary: dict,
      messages: { buttonText }
    }
    return I18N_CONFIG;
  }

  // Get the current locale used for the emoji database
  //
  // @returns {string} the current locale if it is supported by emoji base, or english as the fallback locale
  static locale() {
    let emojiLocale = document.documentElement.getAttribute("lang");

    if (!SUPPORTED_LOCALES.includes(emojiLocale)) {
      const secondaryLocale = emojiLocale?.split("-")[0];
      if (SUPPORTED_LOCALES.includes(secondaryLocale)) {
        emojiLocale = secondaryLocale;
      } else {
        emojiLocale = "en";
      }
    }

    return emojiLocale;
  }

  constructor(elem) {
    const i18nConfig = EmojiButton.i18n();
    const i18nDictionary = i18nConfig.dictionary;
    const buttonText = i18nConfig.messages.buttonText;

    const wrapper = document.createElement("span");
    wrapper.className = "emoji__container"
    const btnContainer = document.createElement("span");
    btnContainer.className = "emoji__trigger"
    const btn = document.createElement("button");
    btn.className = "emoji__button"
    btn.type = "button"
    btn.setAttribute("aria-label", buttonText)
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

    const picker = createPopup({
      autoFocus: "search",
      locale: EmojiButton.locale(),
      i18n: i18nDictionary,
      // shrink the size of the emoji when mobile
      ...(window.matchMedia(`(max-width: ${screens.sm})`).matches && { emojiSize: "1.5rem" })
    }, {
      position: "bottom-end",
      triggerElement: btn,
      className: "emoji__decidim",
      referenceElement
    });

    // Prevent the picker close button to submit the comment form
    picker.closeButton.type = "button";

    let handlerPicker = () => {
      picker.toggle();
    }

    btn.addEventListener("click", handlerPicker);

    elem.addEventListener("characterCounter", (event) => {
      if (event.detail.remaining >= 4) {
        btn.addEventListener("click", handlerPicker);
        btn.removeAttribute("style");
      } else {
        btn.removeEventListener("click", handlerPicker);
        btn.setAttribute("style", "color:lightgrey");
      }
    });

    picker.addEventListener("emoji:select", ({emoji}) => {
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
