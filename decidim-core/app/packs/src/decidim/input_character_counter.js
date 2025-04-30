/* eslint max-lines: ["error", {"max": 350, "skipBlankLines": true}] */

const COUNT_KEY = "%count%";
// How often SR announces the message in relation to maximum characters. E.g.
// if max characters is 1000, screen reader announces the remaining characters
// every 100 (= 0.1 * 1000) characters. This will be "floored" to the closest
// 100 if the maximum characters > 100. E.g. if max characters is 5500, the
// threshold is 500 (= Math.floor(550 / 100) * 100). With 100 or less
// characters, this ratio is omitted and the announce threshold is always set to
// 10.
const SR_ANNOUNCE_THRESHOLD_RATIO = 0.1;
// The number of characters left after which every keystroke will be announced.
const SR_ANNOUNCE_EVERY_THRESHOLD = 10;
const DEFAULT_MESSAGES = {
  charactersAtLeast: {
    one: `at least ${COUNT_KEY} character`,
    other: `at least ${COUNT_KEY} characters`
  },
  charactersLeft: {
    one: `${COUNT_KEY} character left`,
    other: `${COUNT_KEY} characters left`
  }
};
let MESSAGES = DEFAULT_MESSAGES;

export default class InputCharacterCounter {
  static configureMessages(messages) {
    MESSAGES = $.extend(DEFAULT_MESSAGES, messages);
  }

  constructor(input) {
    this.$input = input;
    this.$target = $(this.$input.data("remaining-characters"));
    this.minCharacters = parseInt(this.$input.attr("minlength"), 10);
    this.maxCharacters = parseInt(this.$input.attr("maxlength"), 10);
    this.describeByCounter = this.$input.attr("type") !== "hidden" && typeof this.$input.attr("aria-describedby") === "undefined";

    // Define the closest length for the input "gaps" defined by the threshold.
    if (this.maxCharacters > 10) {
      if (this.maxCharacters > 100) {
        this.announceThreshold = Math.floor(this.maxCharacters * SR_ANNOUNCE_THRESHOLD_RATIO);
      } else {
        this.announceThreshold = 10;
      }

      // The number of characters left after which every keystroke will be announced.
      this.announceEveryThreshold = SR_ANNOUNCE_EVERY_THRESHOLD;
    } else {
      this.announceThreshold = 1;
      this.announceEveryThreshold = 1;
    }

    let targetId = this.$target.attr("id");
    if (typeof targetId === "undefined") {
      if (this.$input.attr("id") && this.$input.attr("id").length > 0) {
        targetId = `${this.$input.attr("id")}_characters`;
      } else {
        targetId = `characters_${Math.random().toString(36).substr(2, 9)}`;
      }
    }

    if (this.$target.length > 0) {
      this.$target.attr("id", targetId)
    } else {
      const span = document.createElement("span")
      span.id = targetId
      span.className = "input-character-counter__text"

      this.$target = $(span)

      const container = document.createElement("span")
      container.className = "input-character-counter__container"
      container.appendChild(span)

      // If input is a hidden for WYSIWYG editor add it at the end
      if (this.$input.parent().is(".editor")) {
        this.$input.parent().append(container);
      } else {
        const wrapper = document.createElement("span")
        wrapper.className = "input-character-counter"

        // The form errors need to be in the same container with the field they
        // belong to for Foundation Abide to show them automatically.
        this.$input.next(".form-error").addBack().wrapAll(wrapper)
        this.$input.after(container);
      }
    }

    if (this.$target.length > 0 && (this.maxCharacters > 0 || this.minCharacters > 0)) {
      // Create the screen reader target element. We do not want to constantly
      // announce every change to screen reader, only occasionally.
      const screenReaderId = `${targetId}_sr`;
      this.$srTarget = $(`#${screenReaderId}`);
      if (!this.$srTarget.length) {
        this.$srTarget = $(
          `<span role="status" id="${screenReaderId}" class="sr-only remaining-character-count-sr" aria-hidden="true"/>`
        );
        this.$target.before(this.$srTarget);
      }
      this.$target.attr("aria-hidden", "true");
      this.$userInput = this.$input;

      // In WYSIWYG editors (TipTap) we need to find the active editor from the
      // DOM node.
      if (this.$input.parent().is(".editor")) {
        // Wait until the next javascript loop so WYSIWYG editors are created
        setTimeout(() => {
          this.editor = this.$input.siblings(".editor-container")[0].querySelector(".ProseMirror").editor;
          this.$userInput = $(this.editor.view.dom);
          this.initialize();
        });
      } else {
        this.initialize();
      }
    }
  }

  initialize() {
    this.updateInputLength();
    this.previousInputLength = this.inputLength;

    this.bindEvents();
    this.setDescribedBy(true);
  }

  setDescribedBy(active) {
    if (!this.describeByCounter) {
      return;
    }

    if (active) {
      this.$userInput.attr("aria-describedby", this.$srTarget.attr("id"));
    } else {
      this.$userInput.removeAttr("aria-describedby");
    }
  }

  bindEvents() {
    if (this.editor) {
      this.editor.on("update", () => {
        this.handleInput();
      });
    } else {
      this.$userInput.on("input", () => {
        this.handleInput();
      });
    }

    this.$userInput.on("keyup", () => {
      this.updateStatus();
    });
    this.$userInput.on("focus", () => {
      this.updateScreenReaderStatus();
    });
    this.$userInput.on("blur", () => {
      this.updateScreenReaderStatus();
      this.setDescribedBy(true);
    });
    if (this.$userInput.get(0) !== null) {
      this.$userInput.get(0).addEventListener("emoji.added", () => {
        this.updateStatus();
      });
    }
    this.updateStatus();
    this.updateScreenReaderStatus();
  }

  getInputLength() {
    return this.inputLength;
  }

  updateInputLength() {
    this.previousInputLength = this.inputLength;
    if (this.editor) {
      this.inputLength = this.editor.storage.characterCount.characters();
    } else {
      this.inputLength = this.$input.val().length;
    }
  }

  handleInput() {
    this.updateInputLength();
    this.checkScreenReaderUpdate();
    // If the input is "described by" the character counter, some screen
    // readers (NVDA) announce the status twice when it is updated. By
    // removing the aria-describedby attribute while the user is typing makes
    // the screen reader announce the status only once.
    this.setDescribedBy(false);
  }

  /**
   * This compares the current inputLength to the previous value and decides
   * whether the user is currently adding or deleting characters from the view.
   *
   * @returns {String} The input direction either "ins" for insert or "del" for
   *   delete.
   */
  getInputDirection() {
    if (this.inputLength < this.previousInputLength) {
      return "del";
    }

    return "ins";
  }

  getScreenReaderLength() {
    const currentLength = this.getInputLength();
    if (this.maxCharacters < 10) {
      return currentLength;
    } else if (this.maxCharacters - currentLength <= this.announceEveryThreshold) {
      return currentLength;
    }

    const srLength = currentLength - currentLength % this.announceThreshold;

    // Prevent the screen reader telling too many characters left if the user
    // deletes a characters. This can cause confusing experience e.g. when the
    // user is closing the maximum amount of characters, so if the previous
    // announcement was "10 characters left" and the user removes one character,
    // the screen reader would announce "100 characters left" next time (when
    // they actually have only 11 characters left). Similar when they are
    // deleting a character at 900 characters, the screen reader would announce
    // "1000 characters left" even when they only have 901 characters left.
    if (this.getInputDirection() === "del") {
      // The first branch makes sure that if the SR length matches the actual
      // length, it will be always announced.
      if (srLength === currentLength) {
        return srLength;
      // The second branch checks that if we are at the final threshold, we
      // should not announce "0 characters left" when the user deletes more than
      // the "announce after every stroke" limit (this.announceEveryThreshold).
      } else if (this.maxCharacters - srLength === this.announceThreshold) {
        return this.announcedAt || currentLength;
      // The third branch checks that when deleting characters, we should
      // announce the next threshold to get accurate annoucement. E.g. when we
      // have 750 characters left and the user deletes 100 characters at once,
      // we should announce "700 characters left" after that deletion.
      } else if (srLength < currentLength) {
        return srLength + this.announceThreshold;
      }
    // This fixes an issue in the following situation:
    // 1. 750 characters left
    // 2. Delete 100 characters in a row
    // 3. SR: "800 characters left" (actual 850)
    // 4. Type one additional character
    // 5. Without this, SR would announce "900 characters left" = confusing
    } else if (srLength < this.announcedAt) {
      return this.announcedAt;
    }

    return srLength;
  }

  getMessages(currentLength = null) {
    const showMessages = [];
    let inputLength = currentLength;
    if (inputLength === null) {
      inputLength = this.getInputLength()
    }

    if (this.minCharacters > 0) {
      let message = MESSAGES.charactersAtLeast.other;
      if (this.minCharacters === 1) {
        message = MESSAGES.charactersAtLeast.one;
      }
      showMessages.push(message.replace(COUNT_KEY, this.minCharacters));
    }

    if (this.maxCharacters > 0) {
      const remaining = this.maxCharacters - inputLength;
      let message = MESSAGES.charactersLeft.other;
      if (remaining === 1) {
        message = MESSAGES.charactersLeft.one;
      }
      this.$userInput[0].dispatchEvent(
        new CustomEvent("characterCounter", {detail: {remaining: remaining}})
      );
      showMessages.push(message.replace(COUNT_KEY, remaining));
    }

    return showMessages;
  }

  updateStatus() {
    this.$target.text(this.getMessages().join(", "));
  }

  checkScreenReaderUpdate() {
    if (this.maxCharacters < 1) {
      return;
    }

    const currentLength = this.getScreenReaderLength();
    if (currentLength === this.announcedAt) {
      return;
    }

    this.announcedAt = currentLength;
    this.updateScreenReaderStatus(currentLength);
  }

  updateScreenReaderStatus(currentLength = null) {
    this.$srTarget.text(this.getMessages(currentLength).join(", "));
  }
}

const createCharacterCounter = ($input) => {
  if (typeof $input !== "undefined" && $input.length) {
    $input.data("remaining-characters-counter", new InputCharacterCounter($input));
  }
}

export {InputCharacterCounter, createCharacterCounter};
