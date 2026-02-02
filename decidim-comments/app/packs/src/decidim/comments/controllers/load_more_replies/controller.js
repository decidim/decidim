import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static get values() {
    return {
      url: String,
      commentGid: String,
      order: String,
      offset: Number,
      perPage: Number
    }
  }

  static get targets() {
    return ["button", "spinner"]
  }

  connect() {
    this.loading = false;
  }

  /**
   * Load more replies when the button is clicked
   * @param {Event} event - The click event from the button
   * @returns {void}
   */
  async loadMore(event) {
    event.preventDefault();

    if (this.loading) {
      return;
    }

    this.loading = true;
    this.showLoadingState();

    try {
      const url = this.buildUrl();
      const response = await this.makeRequest(url);

      if (response.ok) {
        const script = await response.text();
        this.executeScript(script);
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
      "commentable_gid": this.commentGidValue,
      "order": this.orderValue,
      "offset": this.offsetValue,
      "load_more": 1
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
    return tokenElement
      ? tokenElement.getAttribute("content")
      : null;
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
   * Show loading state on the button
   * @private
   * @returns {void}
   */
  showLoadingState() {
    if (this.hasButtonTarget) {
      this.buttonTarget.disabled = true;
      this.buttonTarget.classList.add("loading");
    }
    if (this.hasSpinnerTarget) {
      this.spinnerTarget.classList.remove("hidden");
    }
  }

  /**
   * Hide loading state on the button
   * @private
   * @returns {void}
   */
  hideLoadingState() {
    if (this.hasButtonTarget) {
      this.buttonTarget.disabled = false;
      this.buttonTarget.classList.remove("loading");
    }
    if (this.hasSpinnerTarget) {
      this.spinnerTarget.classList.add("hidden");
    }
  }

  /**
   * Handle error response
   * @private
   * @param {Error} error - The error that occurred
   * @returns {void}
   */
  handleError(error) {
    console.error("Error loading more replies:", error);

    this.dispatch("error", {
      detail: {
        error: error.message,
        element: this.element
      }
    });
  }

  /**
   * Hide the load more button when no more replies are available
   * @public
   * @returns {void}
   */
  hideButton() {
    this.element.remove();
  }
}
