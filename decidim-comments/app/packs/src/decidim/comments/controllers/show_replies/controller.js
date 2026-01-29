import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static get values() {
    return {
      url: String,
      commentGid: String,
      order: String,
      loaded: Boolean
    }
  }

  static get targets() {
    return ["container", "button", "spinner"]
  }

  connect() {
    this.loading = false;
  }

  /**
   * Toggle replies visibility - loads on first click, then toggles
   * @param {Event} event - The click event from the button
   * @returns {void}
   */
  async toggle(event) {
    event.preventDefault();

    if (this.loading) {
      return;
    }

    if (!this.loadedValue) {
      // First time - load replies via AJAX
      await this.loadReplies();
    } else {
      // Already loaded - just toggle visibility
      this.toggleVisibility();
    }
  }

  /**
   * Load replies via AJAX
   * @private
   * @returns {Promise<void>}
   */
  async loadReplies() {
    this.loading = true;
    this.showLoadingState();

    try {
      const url = this.buildUrl();
      const response = await this.makeRequest(url);

      if (response.ok) {
        const script = await response.text();
        this.executeScript(script);
        this.loadedValue = true;
        this.showReplies();
      } else {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
    } catch (error) {
      this.handleError(error);
    } finally {
      this.loading = false;
      this.hideLoadingState();
    }
  }

  /**
   * Build the URL with query parameters for the AJAX request
   * @private
   * @returns {string} The URL with query parameters
   */
  buildUrl() {
    const params = new URLSearchParams({
      commentable_gid: this.commentGidValue,
      order: this.orderValue,
      offset: 0,
      load_more: 1
    });

    return `${this.urlValue}?${params.toString()}`;
  }

  /**
   * Make the HTTP request using fetch
   * @private
   * @param {string} url - The URL to request
   * @returns {Promise<Response>} The fetch response
   */
  async makeRequest(url) {
    const csrfToken = this.getCSRFToken();

    return fetch(url, {
      method: "GET",
      headers: {
        "Accept": "text/javascript",
        "X-Requested-With": "XMLHttpRequest",
        ...(csrfToken && { "X-CSRF-Token": csrfToken })
      },
      credentials: "same-origin"
    });
  }

  /**
   * Get CSRF token from meta tag
   * @private
   * @returns {string|null} The CSRF token or null if not found
   */
  getCSRFToken() {
    const tokenElement = document.querySelector('meta[name="csrf-token"]');
    return tokenElement ? tokenElement.getAttribute("content") : null;
  }

  /**
   * Execute the JavaScript response from the server
   * @private
   * @param {string} script - The JavaScript code to execute
   * @returns {void}
   */
  executeScript(script) {
    const scriptElement = document.createElement("script");
    scriptElement.textContent = script;
    document.body.appendChild(scriptElement);
    document.body.removeChild(scriptElement);
  }

  /**
   * Show loading state
   * @private
   * @returns {void}
   */
  showLoadingState() {
    if (this.hasSpinnerTarget) {
      this.spinnerTarget.classList.remove("hidden");
    }
    if (this.hasButtonTarget) {
      this.buttonTarget.disabled = true;
    }
  }

  /**
   * Hide loading state
   * @private
   * @returns {void}
   */
  hideLoadingState() {
    if (this.hasSpinnerTarget) {
      this.spinnerTarget.classList.add("hidden");
    }
    if (this.hasButtonTarget) {
      this.buttonTarget.disabled = false;
    }
  }

  /**
   * Show replies (after loading or toggling)
   * @private
   * @returns {void}
   */
  showReplies() {
    if (this.hasContainerTarget) {
      this.containerTarget.classList.remove("hidden");
    }
    if (this.hasButtonTarget) {
      this.buttonTarget.setAttribute("aria-expanded", "true");
    }
  }

  /**
   * Hide replies
   * @private
   * @returns {void}
   */
  hideReplies() {
    if (this.hasContainerTarget) {
      this.containerTarget.classList.add("hidden");
    }
    if (this.hasButtonTarget) {
      this.buttonTarget.setAttribute("aria-expanded", "false");
    }
  }

  /**
   * Toggle visibility of replies
   * @private
   * @returns {void}
   */
  toggleVisibility() {
    if (this.hasContainerTarget && this.containerTarget.classList.contains("hidden")) {
      this.showReplies();
    } else {
      this.hideReplies();
    }
  }

  /**
   * Handle error response
   * @private
   * @param {Error} error - The error that occurred
   * @returns {void}
   */
  handleError(error) {
    console.error("Error loading replies:", error);

    this.dispatch("error", {
      detail: {
        error: error.message,
        element: this.element
      }
    });
  }
}
