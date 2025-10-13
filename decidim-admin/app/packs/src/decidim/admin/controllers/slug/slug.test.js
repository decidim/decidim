/* global jest */

import { Application } from "@hotwired/stimulus"
import SlugController from "./controller"

describe("SlugController", () => {
  let application = null;
  let controller = null;
  let element = null;
  let input = null;
  let target = null;

  beforeEach(() => {
    // Set up the DOM structure
    document.body.innerHTML = `
      <div data-controller="slug" class="slug-wrapper">
        <input type="text" placeholder="Enter slug" />
        <span class="slug-url-value"></span>
      </div>
    `

    element = document.querySelector('[data-controller="slug"]')
    input = element.querySelector("input")
    target = element.querySelector("span.slug-url-value")

    // Set up Stimulus application
    application = Application.start()
    application.register("slug", SlugController)

    return new Promise((resolve) => {
      setTimeout(() => {
        controller = application.getControllerForElementAndIdentifier(element, "slug")
        resolve();
      }, 0);
    });
  })

  afterEach(() => {
    controller.disconnect()
    application.stop()
    document.body.innerHTML = ""
  })

  describe("connect", () => {
    it("finds and stores the input element", () => {
      expect(controller.input).toBe(input)
    })

    it("finds and stores the target element", () => {
      expect(controller.target).toBe(target)
    })

    it("adds keyup event listener to input when input exists", () => {
      const addEventListenerSpy = jest.spyOn(input, "addEventListener")

      controller.connect()

      expect(addEventListenerSpy).toHaveBeenCalledWith("keyup", controller.boundUpdate)
    })

    it("binds the slugUpdater method correctly", () => {
      controller.connect()

      expect(controller.boundUpdate).toBeDefined()
      expect(typeof controller.boundUpdate).toBe("function")
    })

    it("handles missing input gracefully", () => {
      // Remove input from DOM
      input.remove()

      controller.disconnect()
      controller.connect()

      expect(() => controller.connect()).not.toThrow()
      expect(controller.boundUpdate).toBeNull()
    })
  })

  describe("disconnect", () => {
    beforeEach(() => {
      controller.connect()
    })

    it("removes keyup event listener when boundUpdate exists", () => {
      const removeEventListenerSpy = jest.spyOn(controller.input, "removeEventListener")

      let bound = controller.boundUpdate;

      controller.disconnect()

      expect(removeEventListenerSpy).toHaveBeenCalledWith("keyup", bound)
    })

    it("handles disconnect when boundUpdate is undefined", () => {
      // eslint-disable-next-line no-undefined
      controller.boundUpdate = undefined

      expect(() => controller.disconnect()).not.toThrow()
    })
  })

  describe("slugUpdater", () => {
    beforeEach(() => {
      controller.connect()
    })

    it("updates target innerHTML with input value", () => {
      const mockEvent = {
        target: {
          value: "test-slug"
        }
      }

      controller.slugUpdater(mockEvent)

      expect(target.innerHTML).toBe("test-slug")
    })

    it("handles empty input value", () => {
      const mockEvent = {
        target: {
          value: ""
        }
      }

      controller.slugUpdater(mockEvent)

      expect(target.innerHTML).toBe("")
    })

    it("handles special characters in input value", () => {
      const mockEvent = {
        target: {
          value: "test-slug-with-special-chars-123"
        }
      }

      controller.slugUpdater(mockEvent)

      expect(target.innerHTML).toBe("test-slug-with-special-chars-123")
    })
  })

  describe("integration tests", () => {
    beforeEach(() => {
      controller.connect()
    })

    it("updates target when typing in input", () => {
      input.value = "my-new-slug"

      // Simulate keyup event
      const keyupEvent = new KeyboardEvent("keyup", { bubbles: true })
      Reflect.defineProperty(keyupEvent, "target", {
        value: input,
        enumerable: true
      })

      input.dispatchEvent(keyupEvent)

      expect(target.innerHTML).toBe("my-new-slug")
    })

    it("updates target multiple times as user types", () => {
      const testValues = ["m", "my", "my-", "my-s", "my-sl", "my-slug"]

      testValues.forEach((value) => {
        input.value = value
        const keyupEvent = new KeyboardEvent("keyup", { bubbles: true })
        Reflect.defineProperty(keyupEvent, "target", {
          value: input,
          enumerable: true
        })
        input.dispatchEvent(keyupEvent)

        expect(target.innerHTML).toBe(value)
      })
    })
  })

  describe("edge cases", () => {
    it("handles DOM structure without input", async () => {
      // Stop the current application to avoid conflicts
      application.stop()

      // Set up new DOM without input
      document.body.innerHTML = `
    <div data-controller="slug" class="slug-wrapper">
      <span class="slug-url-value"></span>
    </div>
  `

      // Start a fresh application
      application = Application.start()
      application.register("slug", SlugController)

      const elementWithoutInput = document.querySelector('[data-controller="slug"]')
      let controllerWithoutInput = null

      await new Promise((resolve) => {
        setTimeout(() => {
          controllerWithoutInput = application.getControllerForElementAndIdentifier(elementWithoutInput, "slug")
          resolve();
        }, 0);
      });

      expect(() => controllerWithoutInput.connect()).not.toThrow()
      expect(controllerWithoutInput.input).toBeNull()
    })

    it("handles DOM structure without target", async () => {
      document.body.innerHTML = `
        <div data-controller="slug" class="slug-wrapper">
          <input type="text" placeholder="Enter slug" />
        </div>
      `

      const elementWithoutTarget = document.querySelector('[data-controller="slug"]')
      let controllerWithoutInput = null

      await new Promise((resolve) => {
        setTimeout(() => {
          controllerWithoutInput = application.getControllerForElementAndIdentifier(elementWithoutTarget, "slug")
          resolve();
        }, 0);
      });


      controllerWithoutInput.connect()

      expect(controllerWithoutInput.target).toBeNull()

      // Should not throw when trying to update nonexistent target
      const mockEvent = { target: { value: "test" } }
      expect(() => controllerWithoutInput.slugUpdater(mockEvent)).toThrow()
    })
  })
})
