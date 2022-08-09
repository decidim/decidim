import { createPopup } from "@picmo/popup-picker";

/**
 * Turns a deep messages object into a dictionary object with a single level and
 * the keys separated with a dot.
 *
 * @param {Object} messages The messages object
 * @param {String | null} prefix Prefix for the messages on recursive calls
 * @returns {Object} The converted dictionary object
 */
const dictionary = (messages, prefix = "") => {
  let final = {};
  Object.keys(messages).forEach((key) => {
    if (typeof messages[key] === "object") {
      final = { ...final, ...dictionary(messages[key], `${key}.`) };
    } else if (key === "") {
      final[prefix.replace(/\.$/, "")] = messages[key];
    } else {
      final[`${prefix}${key}`] = messages[key];
    }
  });

  return final;
};

// eslint-disable-next-line require-jsdoc
export default function addInputEmoji() {
  const containers = document.querySelectorAll("[data-input-emoji]");

  if (containers.length) {
    const allMessages = window.Decidim.config.get("messages");
    let i18n = allMessages.emojis || null;
    if (i18n) {
      i18n = dictionary(i18n);
    }

    containers.forEach((elem) => {
      // if the selector is inside a modal window
      // this allows shows the emoji menu uncut
      const reveal = elem.closest("[data-reveal]")
      if (reveal) {
        reveal.style.overflowY = "unset"
      }

      const wrapper = document.createElement("div");
      wrapper.className = "emoji__container"
      const btnContainer = document.createElement("div");
      btnContainer.className = "emoji__trigger"
      const btn = document.createElement("button");
      btn.type = "button";
      btn.className = "emoji__button"
      btn.innerHTML = '<svg aria-hidden="true" focusable="false" data-prefix="far" data-icon="smile" role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 496 512"><path fill="currentColor" d="M248 8C111 8 0 119 0 256s111 248 248 248 248-111 248-248S385 8 248 8zm0 448c-110.3 0-200-89.7-200-200S137.7 56 248 56s200 89.7 200 200-89.7 200-200 200zm-80-216c17.7 0 32-14.3 32-32s-14.3-32-32-32-32 14.3-32 32 14.3 32 32 32zm160 0c17.7 0 32-14.3 32-32s-14.3-32-32-32-32 14.3-32 32 14.3 32 32 32zm4 72.6c-20.8 25-51.5 39.4-84 39.4s-63.2-14.3-84-39.4c-8.5-10.2-23.7-11.5-33.8-3.1-10.2 8.5-11.5 23.6-3.1 33.8 30 36 74.1 56.6 120.9 56.6s90.9-20.6 120.9-56.6c8.5-10.2 7.1-25.3-3.1-33.8-10.1-8.4-25.3-7.1-33.8 3.1z"></path></svg>'

      const parent = elem.parentNode;
      parent.insertBefore(wrapper, elem);
      wrapper.appendChild(elem);
      wrapper.appendChild(btnContainer);
      btnContainer.appendChild(btn);

      // The form errors need to be in the same container with the field they
      // belong to for Foundation Abide to show them automatically.
      parent.querySelectorAll(".form-error").forEach((el) => wrapper.appendChild(el));

      const picker = createPopup({
        autoFocus: "search",
        locale: document.documentElement.getAttribute("lang"),
        i18n
      }, {
        showCloseButton: true,
        className: "emoji-picker",
        position: {
          position: "absolute",
          right: 0,
          bottom: 0
        },
        rootElement: wrapper
      });

      // Prevent the picker close button to submit the comment form
      picker.closeButton.type = "button";

      const handlerPicker = (ev) => {
        ev.preventDefault();
        ev.stopPropagation();
        picker.toggle();
      }

      btn.addEventListener("click", handlerPicker);

      elem.addEventListener("characterCounter", (event) => {
        if (event.detail.remaining >= 4) {
          btn.addEventListener("click", handlerPicker);
          btnContainer.removeAttribute("style");
        } else {
          btn.removeEventListener("click", handlerPicker);
          btnContainer.setAttribute("style", "color:lightgrey");
        }
      });

      picker.addEventListener("emoji:select", ({emoji}) => {
        elem.value += ` ${emoji} `

        const event = new Event("emoji.added");
        elem.dispatchEvent(event);
      });
    })
  }
};
