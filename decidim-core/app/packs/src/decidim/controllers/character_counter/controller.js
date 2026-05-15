/* eslint max-lines: ["error", 310] */

import { Controller } from "@hotwired/stimulus"
import * as i18n from "src/decidim/refactor/moved/i18n";

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

export default class extends Controller {
  connect() {
    const targetSelector = this.element.dataset.remainingCharacters;

    this.target = targetSelector
      ? document.querySelector(targetSelector)
      : null;
    this.minCharacters = parseInt(this.element.getAttribute("minlength"), 10);
    this.maxCharacters = parseInt(this.element.getAttribute("maxlength"), 10);
    this.describeByCounter = this.element.type !== "hidden" && typeof this.element.getAttribute("aria-describedby") === "undefined";

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

    let targetId = this.target?.getAttribute("id");
    if (typeof targetId === "undefined") {
      if (this.element.getAttribute("id") && this.element.getAttribute("id").length > 0) {
        targetId = `${this.element.getAttribute("id")}_characters`;
      } else {
        targetId = `characters_${Math.random().toString(36).substr(2, 9)}`;
      }
    }

    if (this.target) {
      this.target.setAttribute("id", targetId);
    } else {
      const span = document.createElement("span");
      span.id = targetId;
      span.className = "input-character-counter__text";

      this.target = span;

      this.container = document.createElement("span");
      this.container.className = "input-character-counter__container";
      this.container.appendChild(span);

      // If input is a hidden for WYSIWYG editor add it at the end
      if (this.element.parentElement.classList.contains("editor")) {
        this.element.parentElement.appendChild(this.container);
      } else {
        this.element.after(this.container);
      }
    }

    if (this.target && (this.maxCharacters > 0 || this.minCharacters > 0)) {
      // Create the screen reader target element. We do not want to constantly
      // announce every change to screen reader, only occasionally.
      const screenReaderId = `${targetId}_sr`;
      this.srTarget = document.getElementById(screenReaderId);
      if (!this.srTarget) {
        this.srTarget = document.createElement("span");
        this.srTarget.setAttribute("role", "status");
        this.srTarget.id = screenReaderId;
        this.srTarget.className = "sr-only remaining-character-count-sr";
        this.srTarget.setAttribute("aria-hidden", "true");

        this.target.parentNode.insertBefore(this.srTarget, this.target);
      }
      this.target.setAttribute("aria-hidden", "true");
      this.userInput = this.element;

      // In WYSIWYG editors (TipTap) we need to find the active editor from the
      // DOM node.
      if (this.element.parentElement.classList.contains("editor")) {
        // Wait until the next javascript loop so WYSIWYG editors are created
        setTimeout(() => {
          const editorContainer = this.element.parentElement.querySelector(".editor-container");
          if (editorContainer) {
            const proseMirror = editorContainer.querySelector(".ProseMirror");
            if (proseMirror) {
              this.editor = proseMirror.editor;
              this.userInput = proseMirror;
            }
          }
          this.initializeCounter();
        });
      } else {
        this.initializeCounter();
      }
    }
  }

  initializeCounter() {
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
      this.userInput.setAttribute("aria-describedby", this.srTarget.getAttribute("id"));
    } else {
      this.userInput.removeAttribute("aria-describedby");
    }
  }

  bindEvents() {
    if (this.editor) {
      this.editor.on("update", () => this.handleInput());
    } else {
      this.userInput.addEventListener("input", () => this.handleInput());
    }

    this.userInput.addEventListener("keyup", () => this.updateStatus());
    this.userInput.addEventListener("focus", () => this.updateScreenReaderStatus());

    this.userInput.addEventListener("blur", () => {
      this.updateScreenReaderStatus();
      this.setDescribedBy(true);
    });

    if (this.userInput) {
      this.userInput.addEventListener("emoji.added", () => this.updateStatus());
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
      this.inputLength = this.element.value.length;
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
        // announce the next threshold to get accurate announcement. E.g. when we
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
      let message = i18n.getMessages("characterCounter.charactersAtLeast.other");
      if (this.minCharacters === 1) {
        message = i18n.getMessages("characterCounter.charactersAtLeast.one");
      }
      showMessages.push(message.replace(COUNT_KEY, this.minCharacters));
    }

    if (this.maxCharacters > 0) {
      const remaining = this.maxCharacters - inputLength;
      let message = i18n.getMessages("characterCounter.charactersLeft.other");
      if (remaining === 1) {
        message = i18n.getMessages("characterCounter.charactersLeft.one");
      }
      this.userInput.dispatchEvent(
        new CustomEvent("characterCounter", {detail: {remaining: remaining}})
      );
      showMessages.push(message.replace(COUNT_KEY, remaining));
    }

    return showMessages;
  }

  disconnect() {
    if (this.container) {
      this.container.remove();
    }
  }

  updateStatus() {
    this.target.textContent = this.getMessages().join(", ");
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
    this.srTarget.textContent = this.getMessages(currentLength).join(", ");
  }
}
