import { Controller } from "@hotwired/stimulus"
import * as i18n from "src/decidim/refactor/moved/i18n";

export default class extends Controller {

  static get targets() {
    return ["panel"]
  }

  connect() {
    // The element itself is the action button
    this.panel = this.element.closest(".notification__snippet-actions");

    if (!this.panel) {
      return;
    }
  }

  /**
   * Handle the action click event
   * This method is called when the action button is clicked
   * @param {Event} event - The click event from the toggle button
   * @returns {void}
   */
  async click(event) {
    event.preventDefault();

    const url = this.element.getAttribute("href");
    const method = this.element.getAttribute("data-method") || "GET";

    if (!url) {
      console.error("NotificationAction: No URL found for action");
      return;
    }

    try {
      // Show loading state
      this.showLoadingState();

      // Make the fetch request
      const response = await this.makeRequest(url, method);

      // Handle response
      if (response.ok) {
        const responseData = await this.parseResponse(response);
        this.handleSuccess(responseData);
      } else {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
    } catch (error) {
      this.handleError(error);
    }
  }

  /**
   * Make the HTTP request using fetch
   * @param {string} url - The URL to request
   * @param {string} method - The HTTP method
   * @returns {Promise<Response>} The fetch response
   */
  async makeRequest(url, method) {
    const options = {
      method: method.toUpperCase(),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "X-Requested-With": "XMLHttpRequest"
      },
      credentials: "same-origin"
    };

    // Add CSRF token if available
    const csrfToken = this.getCSRFToken();
    if (csrfToken) {
      options.headers["X-CSRF-Token"] = csrfToken;
    }

    return fetch(url, options);
  }

  /**
   * Parse the response based on content type
   * @param {Response} response - The fetch response
   * @returns {Promise<Object>} Parsed response data
   */
  async parseResponse(response) {
    const contentType = response.headers.get("content-type");

    if (contentType && contentType.includes("application/json")) {
      return response.json();
    }

    return { message: null };
  }

  /**
   * Get CSRF token from meta tag
   * @returns {string|null} The CSRF token or null if not found
   */
  getCSRFToken() {
    const tokenElement = document.querySelector('meta[name="csrf-token"]');
    return tokenElement
      ? tokenElement.getAttribute("content")
      : null;
  }

  /**
   * Show loading state in the panel
   * @returns {void}
   */
  showLoadingState() {
    this.panel.classList.add("spinner-container");

    // Disable all action buttons in the panel
    this.panel.querySelectorAll('[data-controller="notification-action"]').forEach((el) => {
      el.disabled = true;
    });
  }

  /**
   * Handle successful response
   * @param {Object} responseData - The parsed response data
   * @returns {void}
   */
  handleSuccess(responseData) {
    const message = this.extractMessage(responseData);
    this.resolvePanel(message, "success");

    // Dispatch custom event for success
    this.dispatch("success", {
      detail: {
        message,
        responseData,
        element: this.element
      }
    });
  }

  /**
   * Handle error response
   * @param {Error} error - The error that occurred
   * @returns {void}
   */
  handleError(error) {
    const errorMessage = error.message || i18n.getMessages("notifications.action_error");
    this.resolvePanel(i18n.getMessages("notifications.action_error"), "alert");

    // Dispatch custom event for error
    this.dispatch("error", {
      detail: {
        error: errorMessage,
        originalError: error,
        element: this.element
      }
    });
  }

  /**
   * Extract message from response data
   * @param {Object} data - The response data
   * @returns {string|null} The extracted message or null
   */
  extractMessage(data) {
    if (!data) {
      return null;
    }

    // Handle different response formats
    if (data.message) {
      return data.message;
    }

    if (Array.isArray(data) && data[0] && data[0].message) {
      return data[0].message;
    }

    return null;
  }

  /**
   * Resolve the panel state after request completion
   * @param {string|null} message - The message to display
   * @param {string} cssClass - The CSS class for styling (success/alert)
   * @returns {void}
   */
  resolvePanel(message, cssClass) {
    // Remove loading state
    this.panel.classList.remove("spinner-container");

    // Re-enable buttons
    this.panel.querySelectorAll('[data-controller="notification-action"]').forEach((el) => {
      el.disabled = false;
    });

    // Show message if available
    if (message) {
      this.panel.innerHTML = `<div class="flash ${cssClass}">${message}</div>`;
    } else {
      this.panel.innerHTML = "";
    }
  }

  /**
   * Get default error message from Decidim config or fallback
   * @returns {string} The default error message
   */
  getDefaultErrorMessage() {
    i18n.getMessages("notifications.action_error")
  }
}
