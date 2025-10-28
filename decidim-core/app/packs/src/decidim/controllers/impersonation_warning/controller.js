import { Controller } from "@hotwired/stimulus"

/**
 * Impersonation Warning Stimulus Controller
 *
 * Handles the display and management of impersonation session warnings.
 * Shows a countdown timer and automatically reloads the page when the session expires.
 *
 * Usage:
 * <div data-controller="impersonation-warning" data-impersonation-warning-session-ends-at-value="2024-01-01T12:00:00Z">
 *   Session expires in <span class="minutes"></span> minutes
 * </div>
 */
export default class extends Controller {
  static get values() {
    return {
      sessionEndsAt: String
    }
  }

  static get targets() {
    return ["minutes"]
  }

  connect() {
    this.intervalId = null
    this.isUnloading = false

    // Parse the session end time
    this.sessionEndTime = this.parseSessionEndTime()

    if (this.sessionEndTime) {
      this.startCountdown()
      this.setupPageHideListener()
    }
  }

  disconnect() {
    this.cleanup()
  }

  /**
   * Parses the session end time from the value
   * @returns {Date|null} The session end time as a Date object, or null if invalid
   */
  parseSessionEndTime() {
    if (!this.sessionEndsAtValue) {
      console.warn("No session-ends-at value found on impersonation warning element")
      return null
    }

    const parsedDate = new Date(this.sessionEndsAtValue)
    if (isNaN(parsedDate.getTime())) {
      console.warn("Invalid session-ends-at date format:", this.sessionEndsAtValue)
      return null
    }

    return parsedDate
  }

  /**
   * Starts the countdown timer that updates every second
   * @returns {void}
   */
  startCountdown() {
    // Update immediately, then every second
    this.updateCountdown()

    this.intervalId = setInterval(() => {
      this.updateCountdown()
    }, 1000)
  }

  /**
   * Updates the countdown display and checks if session has expired
   * @returns {void}
   */
  updateCountdown() {
    const currentTime = new Date()
    const timeDifference = this.sessionEndTime - currentTime

    // Convert milliseconds to minutes and round
    const minutesRemaining = Math.round(timeDifference / 60000)

    // Update the minutes display if target exists
    if (this.hasMinutesTarget) {
      this.minutesTarget.textContent = minutesRemaining
    }

    // Check if session has expired
    if (timeDifference <= 0) {
      this.handleSessionExpiry()
    }
  }

  /**
   * Handles session expiry by reloading the page
   * @returns {void}
   */
  handleSessionExpiry() {
    this.cleanup()

    // Only reload if the page is not already unloading to prevent infinite reloads
    if (!this.isUnloading) {
      window.location.reload()
    }
  }

  /**
   * Sets up the page hide event listener to prevent reloads during page unload
   * @returns {void}
   */
  setupPageHideListener() {
    this.pageHideHandler = () => {
      this.isUnloading = true
      this.cleanup()
    }

    window.addEventListener("pagehide", this.pageHideHandler)
  }

  /**
   * Cleans up the interval timer and event listeners
   * @returns {void}
   */
  cleanup() {
    if (this.intervalId) {
      clearInterval(this.intervalId)
      this.intervalId = null
    }

    if (this.pageHideHandler) {
      window.removeEventListener("pagehide", this.pageHideHandler)
      this.pageHideHandler = null
    }
  }
}
