/* eslint max-lines: ["error", 390] */
/* global jest */

import { Application } from "@hotwired/stimulus"
import TooltipController from "src/decidim/controllers/tooltip/controller"

describe("TooltipController", () => {
  let application = null;
  let element = null;
  let controller = null;

  beforeEach(() => {
    // Setup DOM
    document.body.innerHTML = `
      <div id="container">
        <button
          id="tooltip-trigger"
          data-controller="tooltip"
          data-tooltip-tooltip-value="<p class=&quot;top&quot; role=&quot;tooltip&quot; aria-hidden=&quot;true&quot;>Test tooltip content</p>"
          title="Original title">
          Trigger button
        </button>
      </div>
    `

    // Initialize Stimulus application
    application = Application.start()
    application.register("tooltip", TooltipController)

    element = document.getElementById("tooltip-trigger")

    // Wait for the controller to be connected
    return new Promise((resolve) => {
      setTimeout(() => {
        controller = application.getControllerForElementAndIdentifier(element, "tooltip")
        resolve();
      }, 0);
    });
  })

  afterEach(() => {
    application.stop()
    document.body.innerHTML = ""

    // Clean up any tooltips that might have been added to body
    document.querySelectorAll('[id^="tooltip"]').forEach((el) => el.remove())
  })

  describe("initialization", () => {
    it("connects successfully", () => {
      expect(controller).toBeDefined()
      expect(controller.element).toBe(element)
    })

    it("creates tooltip element from value", () => {
      expect(controller.tooltip).toBeDefined()
      expect(controller.tooltip.tagName.toLowerCase()).toBe("p")
      expect(controller.tooltip.classList.contains("top")).toBe(true)
    })

    it("removes title attribute from element", () => {
      expect(element.getAttribute("title")).toBeNull()
    })

    it("sets tooltip as hidden initially", () => {
      expect(controller.tooltip.getAttribute("aria-hidden")).toBe("true")
    })

    it("assigns unique id to tooltip", () => {
      expect(controller.tooltip.id).toMatch(/^tooltip-/)
    })
  })

  describe("getAbsolutePosition", () => {
    beforeEach(() => {
      // Mock getBoundingClientRect
      element.getBoundingClientRect = jest.fn(() => ({
        top: 100,
        left: 200,
        width: 150,
        height: 50
      }))

      // Mock window scroll offset
      Reflect.defineProperty(window, "pageXOffset", { value: 10, configurable: true })
      Reflect.defineProperty(window, "pageYOffset", { value: 20, configurable: true })
    })

    it("calculates all 9 positions correctly", () => {
      const positions = controller.getAbsolutePosition(element)

      expect(positions).toEqual({
        topLeft: [210, 120],
        topCenter: [285, 120],
        topRight: [360, 120],
        middleLeft: [210, 145],
        middleCenter: [285, 145],
        middleRight: [360, 145],
        bottomLeft: [210, 170],
        bottomCenter: [285, 170],
        bottomRight: [360, 170]
      })
    })
  })

  describe("tooltip positioning", () => {
    beforeEach(() => {
      element.getBoundingClientRect = jest.fn(() => ({
        top: 100,
        left: 200,
        width: 150,
        height: 50
      }))
      Reflect.defineProperty(window, "pageXOffset", { value: 0, configurable: true })
      Reflect.defineProperty(window, "pageYOffset", { value: 0, configurable: true })
    })

    it("positions tooltip at top center for 'top' class", () => {
      controller.tooltip.classList = ["top"]
      controller.positionTooltip()

      expect(controller.tooltip.style.left).toBe("275px")
      expect(controller.tooltip.style.top).toBe("100px")
    })

    it("positions tooltip at bottom center for 'bottom' class", () => {
      controller.tooltip.classList.remove("top")
      controller.tooltip.classList.add("bottom")
      controller.positionTooltip()

      expect(controller.tooltip.style.left).toBe("275px")
      expect(controller.tooltip.style.top).toBe("150px")
    })

    it("positions tooltip at middle left for 'left' class", () => {
      controller.tooltip.classList.remove("top")
      controller.tooltip.classList.add("left")
      controller.positionTooltip()

      expect(controller.tooltip.style.left).toBe("200px")
      expect(controller.tooltip.style.top).toBe("125px")
    })

    it("positions tooltip at middle right for 'right' class", () => {
      controller.tooltip.classList.remove("top")
      controller.tooltip.classList.add("right")
      controller.positionTooltip()

      expect(controller.tooltip.style.left).toBe("350px")
      expect(controller.tooltip.style.top).toBe("125px")
    })
  })

  describe("arrow offset adjustment", () => {
    beforeEach(() => {
      Reflect.defineProperty(document.documentElement, "clientWidth", { value: 1000, configurable: true })
      Reflect.defineProperty(window, "innerWidth", { value: 1000, configurable: true })
    })

    it("sets arrow offset when tooltip is on left side of screen", () => {
      element.getBoundingClientRect = jest.fn(() => ({
        top: 100, left: 100, width: 150, height: 50
      }))

      controller.tooltip.classList.add("top")
      controller.positionTooltip()

      expect(controller.tooltip.style.getPropertyValue("--arrow-offset")).toBe("80%")
    })

    it("removes arrow offset when tooltip is on right side of screen", () => {
      element.getBoundingClientRect = jest.fn(() => ({
        top: 100, left: 600, width: 150, height: 50
      }))

      controller.tooltip.classList.add("top")
      controller.positionTooltip()

      expect(controller.tooltip.style.getPropertyValue("--arrow-offset")).toBe("")
    })
  })

  describe("tooltip visibility", () => {
    it("shows tooltip when showTooltip is called", () => {
      jest.spyOn(document, "addEventListener")

      controller.showTooltip()

      expect(document.body.contains(controller.tooltip)).toBe(true)
      expect(controller.tooltip.getAttribute("aria-hidden")).toBe("false")
      expect(element.getAttribute("aria-describedby")).toBe(controller.tooltip.id)
    })

    it("hides tooltip when hideTooltip is called", () => {
      // First show the tooltip
      controller.showTooltip()

      controller.hideTooltip()

      expect(controller.tooltip.getAttribute("aria-hidden")).toBe("true")
    })

    it("toggles tooltip visibility", () => {
      const mockEvent = { preventDefault: jest.fn() }

      // First toggle should show
      controller.toggleTooltip(mockEvent)
      expect(controller.tooltip.getAttribute("aria-hidden")).toBe("false")

      // Second toggle should hide
      controller.toggleTooltip(mockEvent)
      expect(controller.tooltip.getAttribute("aria-hidden")).toBe("true")
    })
  })

  describe("outside click handling", () => {
    beforeEach(() => {
      controller.showTooltip()
    })

    it("hides tooltip when clicking outside", () => {
      const outsideElement = document.createElement("div")
      document.body.appendChild(outsideElement)

      const event = { target: outsideElement }
      controller.handleOutsideClick(event)

      expect(controller.tooltip.getAttribute("aria-hidden")).toBe("true")

      outsideElement.remove()
    })

    it("does not hide tooltip when clicking on tooltip", () => {
      const event = { target: controller.tooltip }
      controller.handleOutsideClick(event)

      expect(controller.tooltip.getAttribute("aria-hidden")).toBe("false")
    })

    it("does not hide tooltip when clicking on trigger element", () => {
      const event = { target: element }
      controller.handleOutsideClick(event)

      expect(controller.tooltip.getAttribute("aria-hidden")).toBe("false")
    })
  })

  describe("keyboard handling", () => {
    beforeEach(() => {
      controller.showTooltip()
    })

    it("hides tooltip when escape key is pressed", () => {
      const event = { key: "Escape" }
      controller.handleEscapeKey(event)

      expect(controller.tooltip.getAttribute("aria-hidden")).toBe("true")
    })

    it("does not hide tooltip for other keys", () => {
      const event = { key: "Enter" }
      controller.handleEscapeKey(event)

      expect(controller.tooltip.getAttribute("aria-hidden")).toBe("false")
    })
  })

  describe("mobile detection", () => {
    it("detects mobile user agent", () => {
      Reflect.defineProperty(navigator, "userAgent", {
        value: "Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1",
        configurable: true
      })

      controller.disconnect()
      controller.connect()

      expect(controller.useMobile).toBe(true)
    })

    it("detects desktop user agent", () => {
      Reflect.defineProperty(navigator, "userAgent", {
        value: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
        configurable: true
      })

      controller.disconnect()
      controller.connect()

      expect(controller.useMobile).toBe(false)
    })
  })

  describe("cleanup", () => {
    beforeEach(() => {
      controller.showTooltip()
    })

    it("removes tooltip from DOM when disconnecting", () => {
      expect(document.body.contains(controller.tooltip)).toBe(true)

      controller.disconnect()

      expect(document.body.contains(controller.tooltip)).toBe(false)
    })

    it("removes event listeners when disconnecting", () => {
      jest.spyOn(document, "removeEventListener")

      controller.disconnect()

      expect(document.removeEventListener).toHaveBeenCalledWith("click", controller.outsideClickHandler)
    })
  })

  describe("removeAllTooltips", () => {
    beforeEach(() => {
      // Add some existing tooltips to the DOM
      const tooltip1 = document.createElement("div")
      tooltip1.id = "tooltip-existing1"
      const tooltip2 = document.createElement("div")
      tooltip2.id = "tooltip-existing2"
      const regularDiv = document.createElement("div")
      regularDiv.id = "regular-div"

      document.body.appendChild(tooltip1)
      document.body.appendChild(tooltip2)
      document.body.appendChild(regularDiv)
    })

    it("removes all existing tooltips from DOM", () => {
      expect(document.getElementById("tooltip-existing1")).not.toBeNull()
      expect(document.getElementById("tooltip-existing2")).not.toBeNull()
      expect(document.getElementById("regular-div")).not.toBeNull()

      controller.removeAllTooltips()

      expect(document.getElementById("tooltip-existing1")).toBeNull()
      expect(document.getElementById("tooltip-existing2")).toBeNull()
      expect(document.getElementById("regular-div")).not.toBeNull()
    })
  })

  describe("value changes", () => {
    it("reinitializes when tooltip value changes", () => {
      element.setAttribute("data-tooltip-tooltip-value", "<div class='tooltip bottom'>New content</div>")
      controller.disconnect()
      controller.connect()

      expect(controller.tooltip.classList.contains("bottom")).toBe(true)
    })
  })

  describe("edge cases", () => {
    it("handles empty tooltip value gracefully", () => {
      element.setAttribute("data-tooltip-tooltip-value", "")

      expect(() => {
        controller.tooltipValueChanged()
      }).not.toThrow()
    })

    it("handles non-HTML tooltip content gracefully", () => {
      element.setAttribute("data-tooltip-tooltip-value", "Just plain text")
      controller.disconnect()
      controller.connect()

      expect(controller.tooltip).toBeNull()
    })

    it("handles tooltip without positioning classes", () => {
      element.setAttribute("data-tooltip-tooltip-value", "<div class='tooltip'>No position class</div>")
      controller.tooltipValueChanged()

      expect(() => {
        controller.positionTooltip()
      }).not.toThrow()
    })
  })
})
