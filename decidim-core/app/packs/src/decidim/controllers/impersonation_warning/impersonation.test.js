/* eslint max-lines: ["error", 400] */
/* global global, jest */

import { Application } from "@hotwired/stimulus"
import ImpersonationWarningController from "src/decidim/controllers/impersonation_warning/controller"

describe("ImpersonationWarningController", () => {
  let application = null;
  let element = null;
  let controller = null;
  let minutesTarget = null;
  let clearIntervalSpy = null;

  /**
   * Waits for a Stimulus controller to be connected to a specific element.
   * This function is useful in tests where you need to wait for the controller
   * to be properly initialized before proceeding with test assertions.
   *
   * @async
   * @function waitForControllerConnection
   * @param {Application} app - The Stimulus application instance
   * @param {Element} el - The DOM element that should have the controller
   * @param {string} identifier - The controller identifier (e.g., "impersonation-warning")
   * @returns {Promise<Controller>} A promise that resolves with the connected controller instance
   *
   * @example
   * // Wait for an impersonation warning controller to connect
   * const controller = await waitForControllerConnection(
   *   application,
   *   element,
   *   "impersonation-warning"
   * );
   *
   * @description
   * The function first checks if the controller is already connected. If not,
   * it uses MutationObserver to watch for:
   * - Changes to the element's data-controller attribute
   * - Changes to the DOM tree that might trigger controller connections
   *
   * Once the controller is detected, the observer is disconnected and the
   * controller instance is returned.
   */
  const waitForControllerConnection = async function(app, el, identifier) {
    return new Promise((resolve) => {
      // Check if controller is already connected
      const existingController = app.getControllerForElementAndIdentifier(el, identifier);
      if (existingController) {
        resolve(existingController);
        return;
      }

      // Watch for controller connection
      const observer = new MutationObserver(() => {
        const ctr = app.getControllerForElementAndIdentifier(el, identifier);
        if (ctr) {
          observer.disconnect();
          resolve(ctr);
        }
      });

      // Observe changes to the element's attributes
      observer.observe(element, {
        attributes: true,
        attributeFilter: ["data-controller"]
      });

      // Also observe the application's controller registry changes
      observer.observe(document.body, {
        childList: true,
        subtree: true
      });
    });
  }

  beforeEach(async () => {
    jest.spyOn(console, "warn").mockImplementation(() => {})
    // Mock timers
    jest.useFakeTimers()
    jest.setSystemTime(new Date("2024-01-01T11:55:00Z"))

    // Setup DOM
    document.body.innerHTML = `
      <div
        data-controller="impersonation-warning"
        data-impersonation-warning-session-ends-at-value="2024-01-01T12:00:00Z"
      >
        <span data-impersonation-warning-target="minutes"></span>
      </div>
    `
    clearIntervalSpy = jest.spyOn(global, "clearInterval");

    // Initialize Stimulus application
    application = Application.start()
    application.register("impersonation-warning", ImpersonationWarningController)

    element = document.querySelector('[data-controller="impersonation-warning"]')
    minutesTarget = element.querySelector('[data-impersonation-warning-target="minutes"]')

    controller = await waitForControllerConnection(application, element, "impersonation-warning");
  })

  afterEach(() => {
    console.warn.mockRestore()

    // Clean up timers and intervals
    jest.clearAllTimers()
    jest.useRealTimers()

    // Stop Stimulus application
    application.stop()
    document.body.innerHTML = ""

    clearIntervalSpy.mockRestore();

    // Clear any mocked functions
    jest.clearAllMocks()
  })

  describe("initialization", () => {
    it("connects successfully", () => {
      expect(controller).toBeDefined()
      expect(controller.element).toBe(element)
    })

    it("parses session end time correctly", () => {
      expect(controller.sessionEndTime).toEqual(new Date("2024-01-01T12:00:00Z"))
    })

    it("sets up interval and page hide listener", () => {
      expect(controller.intervalId).not.toBeNull()
      expect(controller.pageHideHandler).toBeDefined()
    })

    it("updates minutes display immediately on connect", () => {
      expect(minutesTarget.textContent).toBe("5")
    })
  })

  describe("parseSessionEndTime", () => {
    it("parses valid ISO date string", () => {
      const result = controller.parseSessionEndTime()
      expect(result).toEqual(new Date("2024-01-01T12:00:00Z"))
    })

    it("returns null for missing value", () => {
      element.removeAttribute("data-impersonation-warning-session-ends-at-value")

      const result = controller.parseSessionEndTime()
      expect(result).toBeNull()
      expect(console.warn).toHaveBeenCalledWith("No session-ends-at value found on impersonation warning element")
    })

    it("returns null for invalid date format", () => {
      element.setAttribute("data-impersonation-warning-session-ends-at-value", "invalid-date")

      const result = controller.parseSessionEndTime()
      expect(result).toBeNull()
      expect(console.warn).toHaveBeenCalledWith("Invalid session-ends-at date format:", "invalid-date")
    })
  })

  describe("countdown functionality", () => {
    it("updates countdown display every second", () => {
      // Initial state: 5 minutes remaining
      expect(minutesTarget.textContent).toBe("5")

      // Advance time by 1 minute
      jest.advanceTimersByTime(60000)
      expect(minutesTarget.textContent).toBe("4")

      // Advance time by another 2 minutes
      jest.advanceTimersByTime(120000)
      expect(minutesTarget.textContent).toBe("2")
    })

    it("handles sub-minute changes correctly", () => {
      // Start with 1.7 minutes remaining
      jest.setSystemTime(new Date("2024-01-01T11:58:18Z"))
      controller.updateCountdown()
      // Rounded up
      expect(minutesTarget.textContent).toBe("2")

      // Move to 1.3 minutes remaining
      jest.setSystemTime(new Date("2024-01-01T11:58:42Z"))
      controller.updateCountdown()
      // Rounded down
      expect(minutesTarget.textContent).toBe("1")
    })

    it("shows 0 minutes when time is very close to expiry", () => {
      jest.setSystemTime(new Date("2024-01-01T11:59:45Z"))
      controller.updateCountdown()
      expect(minutesTarget.textContent).toBe("0")
    })

    it("works without minutes target", () => {
      // Remove the minutes target
      minutesTarget.remove()

      expect(() => {
        controller.updateCountdown()
      }).not.toThrow()
    })
  })

  describe("session expiry handling", () => {
    it("reloads page when session expires", () => {
      // Set time to exactly when session expires
      jest.setSystemTime(new Date("2024-01-01T12:00:00Z"))
      controller.updateCountdown()
      expect(window.location.reload).toHaveBeenCalled();
    })

    it("reloads page when session has already expired", () => {
      // Set time to after session expires
      jest.setSystemTime(new Date("2024-01-01T12:05:00Z"))
      controller.updateCountdown()

      expect(window.location.reload).toHaveBeenCalled()
    })

    it("does not reload when page is unloading", () => {
      const reloadMock = jest.fn()
      Reflect.defineProperty(window.location, "reload", {
        value: reloadMock,
        writable: true
      })

      // Simulate page unloading
      controller.isUnloading = true

      // Set time to after session expires
      jest.setSystemTime(new Date("2024-01-01T12:05:00Z"))
      controller.updateCountdown()

      expect(reloadMock).not.toHaveBeenCalled()
    })

    it("cleans up interval when session expires", () => {
      const reloadMock = jest.fn()
      Reflect.defineProperty(window.location, "reload", {
        value: reloadMock,
        writable: true
      })

      const initialIntervalId = controller.intervalId

      jest.setSystemTime(new Date("2024-01-01T12:00:00Z"))
      controller.updateCountdown()

      expect(controller.intervalId).toBeNull()
      expect(clearInterval).toHaveBeenCalledWith(initialIntervalId)
    })
  })

  describe("page hide event handling", () => {
    it("sets up page hide listener", () => {
      const addEventListenerSpy = jest.spyOn(window, "addEventListener")

      // Reconnect to trigger setup
      controller.disconnect()
      controller.connect()

      expect(addEventListenerSpy).toHaveBeenCalledWith("pagehide", controller.pageHideHandler)
    })

    it("sets isUnloading flag when page hide event fires", () => {
      expect(controller.isUnloading).toBe(false)

      // Trigger pagehide event
      const pagehideEvent = new Event("pagehide")
      window.dispatchEvent(pagehideEvent)

      expect(controller.isUnloading).toBe(true)
    })

    it("cleans up when page hide event fires", () => {
      const initialIntervalId = controller.intervalId

      // Trigger pagehide event
      const pagehideEvent = new Event("pagehide")
      window.dispatchEvent(pagehideEvent)

      expect(controller.intervalId).toBeNull()
      expect(clearInterval).toHaveBeenCalledWith(initialIntervalId)
    })
  })

  describe("cleanup and disconnect", () => {
    it("clears interval on disconnect", () => {
      const initialIntervalId = controller.intervalId
      expect(initialIntervalId).not.toBeNull()

      controller.disconnect()

      expect(controller.intervalId).toBeNull()
      expect(clearInterval).toHaveBeenCalledWith(initialIntervalId)
    })

    it("removes page hide event listener on disconnect", () => {
      const removeEventListenerSpy = jest.spyOn(window, "removeEventListener")
      const handler = controller.pageHideHandler

      controller.disconnect()

      expect(removeEventListenerSpy).toHaveBeenCalledWith("pagehide", handler)
      expect(controller.pageHideHandler).toBeNull()
    })

    it("handles cleanup when interval is already cleared", () => {
      // Clear interval manually first
      controller.cleanup()

      // Should not throw when cleaning up again
      expect(() => {
        controller.cleanup()
      }).not.toThrow()
    })

    it("handles cleanup when page hide handler is already removed", () => {
      // Remove handler manually first
      controller.pageHideHandler = null

      // Should not throw when cleaning up again
      expect(() => {
        controller.cleanup()
      }).not.toThrow()
    })
  })

  describe("edge cases", () => {
    it("handles rapid connect/disconnect cycles", () => {
      controller.disconnect()
      controller.connect()
      controller.disconnect()
      controller.connect()

      expect(controller.intervalId).not.toBeNull()
      expect(controller.pageHideHandler).toBeDefined()
    })

    it("handles time going backwards", () => {
      // Start with 5 minutes remaining
      expect(minutesTarget.textContent).toBe("5")

      // Go back in time (should not happen in real world, but handle gracefully)
      jest.setSystemTime(new Date("2024-01-01T11:50:00Z"))
      controller.updateCountdown()

      expect(minutesTarget.textContent).toBe("10")
    })
  })

  describe("multiple instances", () => {
    it("handles multiple controllers independently", async () => {
      // Create a second element with different expiry time
      const secondElement = document.createElement("div")
      secondElement.setAttribute("data-controller", "impersonation-warning")
      secondElement.setAttribute("data-impersonation-warning-session-ends-at-value", "2024-01-01T12:10:00Z")
      secondElement.innerHTML = '<span data-impersonation-warning-target="minutes"></span>'
      document.body.appendChild(secondElement)

      const secondController = await waitForControllerConnection(application, secondElement, "impersonation-warning");
      const secondMinutesTarget = secondElement.querySelector('[data-impersonation-warning-target="minutes"]')

      // First controller: 5 minutes remaining
      expect(minutesTarget.textContent).toBe("5")
      // Second controller: 15 minutes remaining
      expect(secondMinutesTarget.textContent).toBe("15")

      // Both should have independent intervals
      expect(controller.intervalId).not.toEqual(secondController.intervalId)
    })
  })
})
