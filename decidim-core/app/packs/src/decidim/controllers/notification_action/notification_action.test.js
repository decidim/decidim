/* eslint max-lines: ["error", 405] */
/* global global, jest */

import { Application } from "@hotwired/stimulus"
import NotificationActionController from "src/decidim/controllers/notification_action/controller"

// Mock fetch globally
global.fetch = jest.fn()

// Mock window.Decidim
global.window.Decidim = {
  config: {
    // eslint-disable-next-line consistent-return
    get: jest.fn((key) => {
      if (key === "messages") {
        return {
          notifications: {
            // eslint-disable-next-line camelcase
            action_error: "There was a problem updating the notification"
          }
        }
      }
    })
  }
}

describe("NotificationActionController", () => {
  let application = null;
  let container = null;
  let actionButton = null;
  let panel = null;
  let mockResponse = null;
  let controller = null;

  beforeEach(() => {
    // Reset DOM
    document.body.innerHTML = ""

    // Setup Stimulus application
    application = Application.start()
    application.register("notification-action", NotificationActionController)

    // Create test DOM structure
    container = document.createElement("div")
    container.innerHTML = `
      <div class="notification" data-notification="">
        <div class="notification__wrapper">
          <div class="notification__time" title="Sat, 16 Aug 2025 06:37:14 +0000"> 1 minute ago</div>
          <div class="notification__snippet">
            <span class="notification__snippet-title">
              <a href="/profiles/parts">Paris Feil DO</a> would like to invite you as a co-author of the proposal
              <a href="/processes/corn-turkey/f/9/proposals/91">Create new proposal</a>.
            </span>
            <div class="notification__snippet-actions">
              <div class="flex items-start gap-4">
                <a class="button button__sm button__transparent-secondary" data-controller="notification-action" data-action="click->notification-action#click" data-remote="true" rel="nofollow" data-method="patch" href="/accept">Accept<svg width="1em" height="1em" role="img" aria-hidden="true"><use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-check-line"></use></svg></a>
                <a class="button button__sm button__transparent-secondary" data-controller="notification-action" data-action="click->notification-action#click" data-remote="true" rel="nofollow" data-method="delete" href="/decline">Decline<svg width="1em" height="1em" role="img" aria-hidden="true"><use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-close-circle-line"></use></svg></a>
              </div>
            </div>
          </div>
        </div>
        <a class="notification__button" data-notification-read="" data-remote="true" rel="nofollow" data-method="delete" href="http://alecslupu.go.ro:3000/notifications/1181">
          <span class="sr-only md:not-sr-only">Mark as read</span>
          <svg width="1em" height="1em" role="img" aria-hidden="true" class="fill-current"><use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-check-line"></use></svg>
        </a>
      </div>
    `
    document.body.appendChild(container)

    // Get references to elements
    panel = container.querySelector(".notification__snippet-actions")
    actionButton = container.querySelector('[data-controller="notification-action"]:first-of-type')

    // Setup CSRF token
    const metaTag = document.createElement("meta")
    metaTag.setAttribute("name", "csrf-token")
    metaTag.setAttribute("content", "test-csrf-token")
    document.head.appendChild(metaTag)

    // Setup mock response
    mockResponse = {
      ok: true,
      status: 200,
      headers: {
        get: jest.fn().mockReturnValue("application/json")
      },
      json: jest.fn().mockResolvedValue({ message: "Success!" })
    }

    // Reset mocks
    fetch.mockClear()

    // Wait for the controller to be connected
    return new Promise((resolve) => {
      setTimeout(() => {
        controller = application.getControllerForElementAndIdentifier(actionButton, "notification-action");
        resolve();
      }, 0);
    });
  })

  afterEach(() => {
    application?.stop()
    window.Decidim.config.get.mockClear()
    document.head.innerHTML = ""
    document.body.innerHTML = ""
  })

  describe("Controller Initialization", () => {
    it("connects successfully and finds panel", () => {
      expect(actionButton.dataset.controller).toBe("notification-action")

      expect(controller).toBeDefined()
      expect(controller.panel).toBe(panel)
    })
  })

  describe("Click Handler", () => {
    it("prevents default behavior", async () => {
      fetch.mockResolvedValue(mockResponse)

      const clickEvent = new Event("click")
      const preventDefaultSpy = jest.spyOn(clickEvent, "preventDefault")

      await controller.click(clickEvent)

      expect(preventDefaultSpy).toHaveBeenCalled()
    })

    it("logs error when no URL is found", async () => {
      const consoleSpy = jest.spyOn(console, "error").mockImplementation()

      actionButton.removeAttribute("href")

      await controller.click(new Event("click"))

      expect(consoleSpy).toHaveBeenCalledWith("NotificationAction: No URL found for action")
      consoleSpy.mockRestore()
    })
  })

  describe("HTTP Requests", () => {
    it("makes correct fetch request with PATCH method", async () => {
      fetch.mockResolvedValue(mockResponse)

      await controller.click(new Event("click"))

      expect(fetch).toHaveBeenCalledWith("/accept", {
        method: "PATCH",
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "X-Requested-With": "XMLHttpRequest",
          "X-CSRF-Token": "test-csrf-token"
        },
        credentials: "same-origin"
      })
    })

    it("defaults to GET method when data-method is not specified", async () => {
      fetch.mockResolvedValue(mockResponse)
      actionButton.removeAttribute("data-method")

      await controller.click(new Event("click"))

      expect(fetch).toHaveBeenCalledWith(
        "/accept",
        expect.objectContaining({ method: "GET" })
      )
    })

    it("includes CSRF token when available", async () => {
      fetch.mockResolvedValue(mockResponse)

      await controller.click(new Event("click"))

      expect(fetch).toHaveBeenCalledWith(
        "/accept",
        expect.objectContaining({
          headers: expect.objectContaining({
            "X-CSRF-Token": "test-csrf-token"
          })
        })
      )
    })

    it("works without CSRF token", async () => {
      document.head.innerHTML = ""
      fetch.mockResolvedValue(mockResponse)

      await controller.click(new Event("click"))

      expect(fetch).toHaveBeenCalledWith(
        "/accept",
        expect.objectContaining({
          headers: expect.not.objectContaining({
            "X-CSRF-Token": expect.any(String)
          })
        })
      )
    })
  })

  describe("Loading States", () => {
    it("shows loading state during request", async () => {
      let resolvePromise = null;
      const fetchPromise = new Promise((resolve) => {
        resolvePromise = resolve
      })
      fetch.mockReturnValue(fetchPromise)

      const clickPromise = controller.click(new Event("click"))

      // Check loading state is active
      expect(panel.classList.contains("spinner-container")).toBe(true)
      expect(actionButton.disabled).toBe(true)

      // Resolve the request
      resolvePromise(mockResponse)
      await clickPromise

      // Check loading state is removed
      expect(panel.classList.contains("spinner-container")).toBe(false)
      expect(actionButton.disabled).toBe(false)
    })

    it("disables all action buttons in panel during request", async () => {
      const secondButton = container.querySelector('[data-controller="notification-action"]:last-of-type')

      let resolvePromise = null;
      const fetchPromise = new Promise((resolve) => {
        resolvePromise = resolve
      })
      fetch.mockReturnValue(fetchPromise)

      const clickPromise = controller.click(new Event("click"))

      // Both buttons should be disabled
      expect(actionButton.disabled).toBe(true)
      expect(secondButton.disabled).toBe(true)

      // Resolve and check they are re-enabled
      resolvePromise(mockResponse)
      await clickPromise

      expect(actionButton.disabled).toBe(false)
      expect(secondButton.disabled).toBe(false)
    })
  })

  describe("Success Handling", () => {
    it("handles successful response with message", async () => {
      const successResponse = {
        ...mockResponse,
        json: jest.fn().mockResolvedValue({ message: "Action completed successfully!" })
      }
      fetch.mockResolvedValue(successResponse)

      await controller.click(new Event("click"))

      expect(panel.innerHTML).toBe('<div class="flash success">Action completed successfully!</div>')
    })

    it("handles successful response without message", async () => {
      const successResponse = {
        ...mockResponse,
        json: jest.fn().mockResolvedValue({})
      }
      fetch.mockResolvedValue(successResponse)

      await controller.click(new Event("click"))

      expect(panel.innerHTML).toBe("")
    })

    it("dispatches success event", async () => {
      fetch.mockResolvedValue(mockResponse)

      const eventSpy = jest.fn()
      actionButton.addEventListener("notification-action:success", eventSpy)

      await controller.click(new Event("click"))

      expect(eventSpy).toHaveBeenCalledWith(
        expect.objectContaining({
          detail: expect.objectContaining({
            message: "Success!",
            element: actionButton
          })
        })
      )
    })
  })

  describe("Error Handling", () => {
    it("handles HTTP error responses", async () => {
      const errorResponse = {
        ok: false,
        status: 422,
        statusText: "Unprocessable Entity"
      }
      fetch.mockResolvedValue(errorResponse)

      await controller.click(new Event("click"))

      expect(panel.innerHTML).toBe('<div class="flash alert">There was a problem updating the notification</div>')
    })

    it("handles network errors", async () => {
      fetch.mockRejectedValue(new Error("Network error"))

      await controller.click(new Event("click"))

      expect(panel.innerHTML).toBe('<div class="flash alert">There was a problem updating the notification</div>')
    })

    it("uses fallback error message", async () => {
      fetch.mockRejectedValue(new Error())

      await controller.click(new Event("click"))

      expect(panel.innerHTML).toBe('<div class="flash alert">There was a problem updating the notification</div>')
    })

    it("dispatches error event", async () => {
      fetch.mockRejectedValue(new Error("Test error"))

      const eventSpy = jest.fn()
      actionButton.addEventListener("notification-action:error", eventSpy)

      await controller.click(new Event("click"))

      expect(eventSpy).toHaveBeenCalledWith(
        expect.objectContaining({
          detail: expect.objectContaining({
            error: "Test error",
            element: actionButton
          })
        })
      )
    })
  })

  describe("Response Parsing", () => {
    it("parses JSON responses", async () => {
      const jsonResponse = {
        ok: true,
        headers: {
          get: jest.fn().mockReturnValue("application/json")
        },
        json: jest.fn().mockResolvedValue({ message: "JSON parsed" })
      }
      fetch.mockResolvedValue(jsonResponse)

      const result = await controller.parseResponse(jsonResponse)

      expect(result).toEqual({ message: "JSON parsed" })
    })

    it("handles non-JSON responses", async () => {
      const textResponse = {
        ok: true,
        headers: {
          get: jest.fn().mockReturnValue("text/html")
        }
      }

      const result = await controller.parseResponse(textResponse)

      expect(result).toEqual({ message: null })
    })
  })

  describe("Message Extraction", () => {
    it("extracts message from simple object", () => {
      expect(controller.extractMessage({ message: "Simple message" })).toBe("Simple message")
    })

    it("extracts message from array format", () => {
      expect(controller.extractMessage([{ message: "Array message" }])).toBe("Array message")
    })

    it("returns null for data without message", () => {
      expect(controller.extractMessage({})).toBeNull()
      expect(controller.extractMessage(null)).toBeNull()
    })
  })
})
