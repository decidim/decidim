/* eslint max-lines: ["error", 400] */

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.options = {
      noDataFoundMessage: this.element.getAttribute("data-noresults") || "No results found",
      debounceDelay: 250,
      menuItemLimit: 5
    };

    this.suggestion = null;
    this.suggestions = [];
    this.selectedIndex = -1;
    this.isActive = false;
    this.currentMentionStart = null;
    this.requestId = 0;
    this.isInitialized = false;

    // Prevent initialization inside editor components
    if (this.element.parentElement && this.element.parentElement.classList.contains("editor")) {
      return;
    }

    this.createSuggestionContainer();
    this.setupEventListeners();
    this.isInitialized = true;
  }

  disconnect() {
    if (this.suggestion) {
      this.suggestion.remove();
    }

    this.element.removeEventListener("focusin", this.handleFocusIn);
    this.element.removeEventListener("focusout", this.handleFocusOut);
    this.element.removeEventListener("input", this.handleInput);
    this.element.removeEventListener("keydown", this.handleKeyDown);
    document.removeEventListener("click", this.handleDocumentClick);

    this.suggestion = null;
    this.suggestions = [];
    this.isInitialized = false;
  }

  createSuggestionContainer() {
    this.suggestion = document.createElement("div");
    this.suggestion.classList.add("editor-suggestions", "hidden", "hide");
    document.body.append(this.suggestion);
    this.suggestion.addEventListener("mousedown", (event) => event.preventDefault());

    this.performRemoteSearch = this.debounce(this.performRemoteSearch.bind(this), this.options.debounceDelay);
  }

  setupEventListeners() {
    this.handleFocusIn = this.handleFocusIn.bind(this);
    this.handleFocusOut = this.handleFocusOut.bind(this);
    this.handleInput = this.handleInput.bind(this);
    this.handleKeyDown = this.handleKeyDown.bind(this);
    this.handleDocumentClick = this.handleDocumentClick.bind(this);

    this.element.addEventListener("focusin", this.handleFocusIn);
    this.element.addEventListener("focusout", this.handleFocusOut);
    this.element.addEventListener("input", this.handleInput);
    this.element.addEventListener("keydown", this.handleKeyDown);
    document.addEventListener("click", this.handleDocumentClick);
  }

  handleFocusIn() {
    if (this.element.parentNode) {
      this.element.parentNode.classList.add("is-active");
    }
  }

  handleFocusOut(event) {
    if (this.suggestion && this.suggestion.contains(event.relatedTarget)) {
      return;
    }

    this.hideSuggestions();
    const parent = event.target.parentNode;

    if (parent && parent.classList.contains("is-active")) {
      parent.classList.remove("is-active");
    }
  }

  handleInput() {
    const trigger = this.mentionTriggerAtCursor();
    if (!trigger) {
      this.hideSuggestions();
      return;
    }

    this.currentMentionStart = trigger.start;
    this.performRemoteSearch(trigger.query);
  }

  handleKeyDown(event) {
    if (!this.isActive) {
      return;
    }

    if (event.key === "Escape") {
      event.preventDefault();
      this.hideSuggestions();
    } else if (event.key === "ArrowDown") {
      event.preventDefault();
      this.updateSelectedIndex(1);
      this.renderSuggestions();
    } else if (event.key === "ArrowUp") {
      event.preventDefault();
      this.updateSelectedIndex(-1);
      this.renderSuggestions();
    } else if (event.key === "Enter") {
      event.preventDefault();
      this.selectSuggestion(this.selectedIndex);
    }
  }

  handleDocumentClick(event) {
    if (this.element === event.target || this.element.contains(event.target) || this.suggestion?.contains(event.target)) {
      return;
    }

    this.hideSuggestions();
  }

  mentionTriggerAtCursor() {
    const value = this.element.value || "";
    const caretPosition = this.element.selectionStart;

    if (typeof caretPosition !== "number") {
      return null;
    }

    const textBeforeCursor = value.slice(0, caretPosition);
    const mentionMatch = textBeforeCursor.match(/(?:^|\s)@([\w.-]{2,})$/);
    if (!mentionMatch) {
      return null;
    }

    return {
      query: mentionMatch[1],
      start: caretPosition - mentionMatch[1].length - 1
    };
  }

  performRemoteSearch(text) {
    const currentRequestId = this.requestId + 1;
    this.requestId = currentRequestId;

    const query = `{users(filter:{wildcard:"${text}"}){nickname,name,avatarUrl,__typename}}`;
    const apiPath = window.Decidim.config.get("api_path");

    this.makeRequest(apiPath, { query }).
      then((response) => {
        if (this.requestId !== currentRequestId) {
          return;
        }

        const data = response.data.users || [];
        const sortedData = data.sort((first, second) => first.nickname.localeCompare(second.nickname));
        this.suggestions = sortedData.slice(0, this.options.menuItemLimit);
        this.selectedIndex = this.suggestions.length > 0
          ? 0
          : -1;
        this.renderSuggestions({ showNoResults: true });
      }).
      catch(() => {
        if (this.requestId !== currentRequestId) {
          return;
        }

        this.suggestions = [];
        this.selectedIndex = -1;
        this.renderSuggestions({ showNoResults: true });
      });
  }

  makeRequest(url, data) {
    return fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name=csrf-token]")?.getAttribute("content") || ""
      },
      body: JSON.stringify(data)
    }).then((response) => {
      if (!response.ok) {
        throw new Error("Network response was not ok");
      }
      return response.json();
    });
  }

  renderSuggestions({ showNoResults = false } = {}) {
    if (!this.suggestion) {
      return;
    }

    this.suggestion.innerHTML = "";

    if (this.suggestions.length < 1) {
      this.isActive = false;

      if (showNoResults && this.options.noDataFoundMessage) {
        const noResultsItem = document.createElement("button");
        noResultsItem.type = "button";
        noResultsItem.disabled = true;
        noResultsItem.classList.add("editor-suggestions-item", "editor-suggestions-item-disabled");
        noResultsItem.textContent = this.options.noDataFoundMessage;
        this.suggestion.append(noResultsItem);
        this.positionSuggestionMenu();
        this.suggestion.classList.remove("hidden", "hide");
      } else {
        this.suggestion.classList.add("hidden", "hide");
      }

      return;
    }

    this.suggestions.forEach((item, index) => {
      const suggestionItem = document.createElement("button");
      suggestionItem.type = "button";
      suggestionItem.classList.add("editor-suggestions-item");
      suggestionItem.dataset.index = index;

      if (item.avatarUrl) {
        const avatar = document.createElement("img");
        avatar.classList.add("editor-suggestions-item-avatar");
        avatar.src = item.avatarUrl;
        avatar.alt = item.name || item.nickname;
        suggestionItem.append(avatar);
      }

      const label = document.createElement("span");
      label.classList.add("editor-suggestions-item-label");
      label.textContent = `${item.nickname} (${item.name})`;
      suggestionItem.append(label);

      if (index === this.selectedIndex) {
        suggestionItem.dataset.selected = "true";
      }

      suggestionItem.addEventListener("click", (event) => {
        event.preventDefault();
        this.selectSuggestion(index);
      });

      this.suggestion.append(suggestionItem);
    });

    this.positionSuggestionMenu();
    this.isActive = true;
    this.suggestion.classList.remove("hidden", "hide");
  }

  positionSuggestionMenu() {
    if (!this.suggestion || this.currentMentionStart === null) {
      return;
    }

    const coordinates = this.coordinatesForTextIndex(this.currentMentionStart);
    if (!coordinates) {
      return;
    }

    Object.assign(this.suggestion.style, {
      position: "absolute",
      top: `${coordinates.top}px`,
      left: `${coordinates.left}px`
    });
  }

  coordinatesForTextIndex(index) {
    const element = this.element;
    const styles = window.getComputedStyle(element);
    const elementRect = element.getBoundingClientRect();
    const borderTopWidth = parseFloat(styles.borderTopWidth) || 0;
    const borderLeftWidth = parseFloat(styles.borderLeftWidth) || 0;
    const lineHeight = parseFloat(styles.lineHeight) || 16;

    const mirror = document.createElement("div");
    const mirrorStyles = [
      "fontFamily",
      "fontSize",
      "fontWeight",
      "fontStyle",
      "letterSpacing",
      "textTransform",
      "wordSpacing",
      "textIndent",
      "boxSizing",
      "width",
      "paddingTop",
      "paddingRight",
      "paddingBottom",
      "paddingLeft",
      "borderTopWidth",
      "borderRightWidth",
      "borderBottomWidth",
      "borderLeftWidth",
      "borderStyle",
      "lineHeight"
    ];

    mirrorStyles.forEach((property) => {
      mirror.style[property] = styles[property];
    });

    mirror.style.position = "absolute";
    mirror.style.visibility = "hidden";
    mirror.style.whiteSpace = element.nodeName === "TEXTAREA"
      ? "pre-wrap"
      : "pre";
    mirror.style.overflowWrap = "break-word";
    mirror.style.top = "0";
    mirror.style.left = "-9999px";

    const before = document.createTextNode((element.value || "").slice(0, index));
    const marker = document.createElement("span");
    marker.textContent = "@";

    mirror.append(before);
    mirror.append(marker);
    document.body.append(mirror);

    const top = elementRect.top + window.scrollY + marker.offsetTop - element.scrollTop + borderTopWidth + lineHeight;
    const left = elementRect.left + window.scrollX + marker.offsetLeft - element.scrollLeft + borderLeftWidth;

    mirror.remove();

    return { top, left };
  }

  updateSelectedIndex(direction) {
    if (this.suggestions.length < 1) {
      this.selectedIndex = -1;
      return;
    }

    const maxIndex = this.suggestions.length - 1;
    const nextIndex = this.selectedIndex + direction;

    this.selectedIndex = Math.max(0, Math.min(nextIndex, maxIndex));
  }

  selectSuggestion(index) {
    const selectedItem = this.suggestions[index];
    if (!selectedItem || this.currentMentionStart === null) {
      return;
    }

    const cursorPosition = this.element.selectionStart;
    const value = this.element.value || "";
    const mentionValue = `${selectedItem.nickname} `;
    const newValue = `${value.slice(0, this.currentMentionStart)}${mentionValue}${value.slice(cursorPosition)}`;

    this.element.value = newValue;

    const newPosition = this.currentMentionStart + mentionValue.length;
    this.element.setSelectionRange(newPosition, newPosition);

    this.element.dispatchEvent(new Event("input", { bubbles: true }));
    this.hideSuggestions();
  }

  hideSuggestions() {
    if (!this.suggestion) {
      return;
    }

    this.isActive = false;
    this.currentMentionStart = null;
    this.selectedIndex = -1;
    this.suggestions = [];
    this.suggestion.classList.add("hidden", "hide");
    this.suggestion.innerHTML = "";
  }

  debounce(callback, wait) {
    let timeout = null;
    return (...args) => {
      if (timeout) {
        clearTimeout(timeout);
      }
      timeout = setTimeout(() => {
        timeout = null;
        Reflect.apply(callback, this, args)
      }, wait);
    };
  }

  get initialized() {
    return this.isInitialized;
  }
}
