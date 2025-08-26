import { Controller } from "@hotwired/stimulus"
import Tribute from "src/decidim/vendor/tribute";

export default class extends Controller {
  connect() {
    this.options = {
      noDataFoundMessage: this.element.getAttribute("data-noresults") || "No results found",
      debounceDelay: 250,
      menuItemLimit: 5
    };

    this.tribute = null;
    this.isInitialized = false;

    // Prevent initialization inside editor components
    if (this.element.parentElement && this.element.parentElement.classList.contains("editor")) {
      return;
    }

    this.createTribute();
    this.attachTribute();
    this.setupEventListeners();
    this.isInitialized = true;
  }

  disconnect() {
    if (this.tribute) {
      this.tribute.detach(this.element);
    }

    this.element.removeEventListener("focusin", this.handleFocusIn);
    this.element.removeEventListener("focusout", this.handleFocusOut);
    this.element.removeEventListener("input", this.handleInput);

    this.tribute = null;
    this.isInitialized = false;
  }

  /**
   * Create and configure the Tribute instance
   * @returns {void}
   * @private
   */
  createTribute() {
    const noMatchTemplate = this.options.noDataFoundMessage
      ? () => `<li>${this.options.noDataFoundMessage}</li>`
      : null;

    this.tribute = new Tribute({
      trigger: "@",
      values: this.debounce((text, callback) => {
        this.performRemoteSearch(text, callback);
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
  attachTribute() {
    // if (this.element.hasAttribute("data-tribute")) {
    //   return;
    // }

    if (this.tribute) {
      this.tribute.attach(this.element);
    }
  }

  /**
   * Set up event listeners for the element
   * @returns {void}
   * @private
   */
  setupEventListeners() {
    // Handle focus events to set menu container
    this.element.addEventListener("focusin", this.handleFocusIn.bind(this));
    this.element.addEventListener("focusout", this.handleFocusOut.bind(this));
    this.element.addEventListener("input", this.handleInput.bind(this));
  }

  /**
   * Handle focus in event
   * @param {Event} event - The focus in event
   * @returns {void}
   * @private
   */
  handleFocusIn(event) {
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
  handleFocusOut(event) {
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
  handleInput(event) {
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
  performRemoteSearch(text, callback) {
    const query = `{users(filter:{wildcard:"${text}"}){nickname,name,avatarUrl,__typename}}`;
    const apiPath = window.Decidim.config.get("api_path");

    this.makeRequest(apiPath, { query }).
      then((response) => {
        const data = response.data.users || [];
        callback(data);
      }).
      catch(() => {
        callback([]);
      }).
      finally(() => {
        this.adjustTributeContainer();
      });
  }

  /**
   * Make an HTTP POST request
   * @param {string} url - The request URL
   * @param {Object} data - The request data
   * @returns {Promise} The request promise
   * @private
   */
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

  /**
   * Adjust the tribute container positioning and styling
   * @returns {void}
   * @private
   */
  adjustTributeContainer() {
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

  /**
   * Check if the component is initialized
   * @returns {boolean} True if initialized, false otherwise
   */
  get initialized() {
    return this.isInitialized;
  }
}
