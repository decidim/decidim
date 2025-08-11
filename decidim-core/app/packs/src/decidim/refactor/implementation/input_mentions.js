/* eslint max-lines: ["error", 350] */
import Tribute from "src/decidim/vendor/tribute";

/**
 * MentionsComponent handles user mentions functionality using the Tribute library.
 * It provides autocomplete suggestions for user mentions triggered by the "@" symbol.
 */
export default class MentionsComponent {

  /**
   * Initialize the MentionsComponent
   * @param {HTMLElement} element - The DOM element to attach mentions to
   * @param {Object} options - Configuration options
   */
  constructor(element, options = {}) {
    this.element = element;
    this.options = {
      noDataFoundMessage: element.getAttribute("data-noresults") || "No results found",
      debounceDelay: 250,
      menuItemLimit: 5,
      ...options
    };

    this.tribute = null;
    this.isInitialized = false;

    this._init();
  }

  /**
   * Initialize the component if conditions are met
   * @returns {void}
   * @private
   */
  _init() {
    // Prevent initialization inside editor components
    if (this.element.parentElement && this.element.parentElement.classList.contains("editor")) {
      return;
    }

    this._createTribute();
    this._attachTribute();
    this._setupEventListeners();
    this.isInitialized = true;
  }

  /**
   * Create and configure the Tribute instance
   * @returns {void}
   * @private
   */
  _createTribute() {
    const noMatchTemplate = this.options.noDataFoundMessage
      ? () => `<li>${this.options.noDataFoundMessage}</li>`
      : null;

    this.tribute = new Tribute({
      trigger: "@",
      values: this._debounce((text, callback) => {
        this._performRemoteSearch(text, callback);
      }, this.options.debounceDelay),
      positionMenu: true,
      menuContainer: null,
      allowSpaces: true,
      menuItemLimit: this.options.menuItemLimit,
      fillAttr: "nickname",
      selectClass: "highlight",
      noMatchTemplate: noMatchTemplate,
      lookup: (item) => item.nickname + item.name,
      selectTemplate: (item) => {
        if (typeof item === "undefined") {
          return null;
        }
        return item.original.nickname;
      },
      menuItemTemplate: (item) => {
        return `
          <img src="${item.original.avatarUrl}" alt="author-avatar">
          <strong>${item.original.nickname}</strong>
          <small>${item.original.name}</small>
        `;
      }
    });
  }

  /**
   * Attach the Tribute instance to the element
   * @returns {void}
   * @private
   */
  _attachTribute() {
    if (this.tribute && this.element) {
      this.tribute.attach(this.element);
    }
  }

  /**
   * Set up event listeners for the element
   * @returns {void}
   * @private
   */
  _setupEventListeners() {
    if (!this.element) {
      return;
    }

    // Handle focus events to set menu container
    this.element.addEventListener("focusin", this._handleFocusIn.bind(this));
    this.element.addEventListener("focusout", this._handleFocusOut.bind(this));
    this.element.addEventListener("input", this._handleInput.bind(this));
  }

  /**
   * Handle focus in event
   * @param {Event} event - The focus in event
   * @returns {void}
   * @private
   */
  _handleFocusIn(event) {
    if (this.tribute) {
      this.tribute.menuContainer = event.target.parentNode;
    }
  }

  /**
   * Handle focus out event
   * @param {Event} event - The focus out event
   * @returns {void}
   * @private
   */
  _handleFocusOut(event) {
    const parent = event.target.parentNode;

    if (parent && parent.classList.contains("is-active")) {
      parent.classList.remove("is-active");
    }
  }

  /**
   * Handle input event
   * @param {Event} event - The input event
   * @returns {void}
   * @private
   */
  _handleInput(event) {
    const parent = event.target.parentNode;

    if (!parent) {
      return;
    }

    if (this.tribute && this.tribute.isActive) {
      // Move the tribute container to the correct parent
      const tributeContainer = document.querySelector(".tribute-container");
      if (tributeContainer) {
        parent.appendChild(tributeContainer);
      }

      parent.classList.add("is-active");
    } else {
      parent.classList.remove("is-active");
    }
  }

  /**
   * Perform remote search for users
   * @param {string} text - The search text
   * @param {Function} callback - The callback function to call with results
   * @returns {void}
   * @private
   */
  _performRemoteSearch(text, callback) {
    const query = `{users(filter:{wildcard:"${text}"}){nickname,name,avatarUrl,__typename}}`;
    const apiPath = window.Decidim.config.get("api_path");

    this._makeRequest(apiPath, { query }).
      then((response) => {
        const data = response.data.users || [];
        callback(data);
      }).
      catch(() => {
        callback([]);
      }).
      finally(() => {
        this._adjustTributeContainer();
      });
  }

  /**
   * Make an HTTP POST request
   * @param {string} url - The request URL
   * @param {Object} data - The request data
   * @returns {Promise} The request promise
   * @private
   */
  _makeRequest(url, data) {
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

  /**
   * Adjust the tribute container positioning and styling
   * @returns {void}
   * @private
   */
  _adjustTributeContainer() {
    if (!this.tribute || !this.tribute.current || !this.tribute.current.element) {
      return;
    }

    const parent = this.tribute.current.element.parentNode;
    if (parent) {
      parent.classList.add("is-active");

      const tributeContainer = parent.querySelector(".tribute-container");
      if (tributeContainer) {
        // Remove inline styles for absolute positioning
        tributeContainer.removeAttribute("style");
      }
    }
  }

  /**
   * Create a debounced version of a function
   * @param {Function} callback - The function to debounce
   * @param {number} wait - The debounce delay in milliseconds
   * @returns {Function} The debounced function
   * @private
   */
  _debounce(callback, wait) {
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

  /**
   * Attach mentions to a new element
   * @param {HTMLElement} element - The element to attach mentions to
   * @returns {void}
   */
  attachToElement(element) {
    if (!element || !this.tribute) {
      return;
    }

    this.tribute.attach(element);

    // Handle Tribute bug where menu might be removed from DOM
    if (this.tribute.menu && !document.body.contains(this.tribute.menu)) {
      this.tribute.range.getDocument().body.appendChild(this.tribute.menu);
    }

    // Set up event listeners for the new element
    element.addEventListener("focusin", this._handleFocusIn.bind(this));
    element.addEventListener("focusout", this._handleFocusOut.bind(this));
    element.addEventListener("input", this._handleInput.bind(this));
  }

  /**
   * Destroy the component and clean up resources
   * @returns {void}
   */
  destroy() {
    if (this.tribute) {
      this.tribute.detach(this.element);
    }

    if (this.element) {
      this.element.removeEventListener("focusin", this._handleFocusIn);
      this.element.removeEventListener("focusout", this._handleFocusOut);
      this.element.removeEventListener("input", this._handleInput);
    }

    this.tribute = null;
    this.element = null;
    this.isInitialized = false;
  }

  /**
   * Check if the component is initialized
   * @returns {boolean} True if initialized, false otherwise
   */
  get initialized() {
    return this.isInitialized;
  }
}


