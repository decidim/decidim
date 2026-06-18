/* global jest */
import { Application } from "@hotwired/stimulus"
import MainMenuController from "src/decidim/controllers/main_menu/controller"

describe("MainMenuController", () => {
  const makeFocusable = (element) => {
    Object.defineProperty(element, "offsetWidth", { configurable: true, value: 1 })
    Object.defineProperty(element, "offsetHeight", { configurable: true, value: 1 })
    return element
  }

  let application = null
  let controller = null
  let menuButton = null
  let menuContainer = null
  let closeButton = null

  const buildDom = () => {
    document.body.innerHTML = `
      <button
        data-controller="main-menu"
        data-target="main-menu-container"
        data-close-button="main-menu-close"
        aria-expanded="false"
      >
        Menu
      </button>
      <div id="main-menu-container" aria-hidden="true">
        <div id="main-menu-item"></div>
      </div>
      <button id="main-menu-close">Close</button>
    `
  }

  const startController = () => new Promise((resolve) => {
    setTimeout(() => {
      controller = application.getControllerForElementAndIdentifier(menuButton, "main-menu")
      resolve()
    }, 0)
  })

  beforeEach(() => {
    application = Application.start()
    application.register("main-menu", MainMenuController)
    buildDom()

    menuButton = document.querySelector('[data-controller="main-menu"]')
    menuContainer = document.getElementById("main-menu-container")
    closeButton = document.getElementById("main-menu-close")

    window.focusGuard = {
      trap: jest.fn(),
      disable: jest.fn()
    }

    jest.spyOn(window, "scrollTo").mockImplementation(() => {})

    return startController()
  })

  afterEach(() => {
    application.stop()
    document.body.innerHTML = ""
    jest.useRealTimers()
    jest.restoreAllMocks()
  })

  describe("connect", () => {
    it("binds expected event listeners", () => {
      const buttonSpy = jest.spyOn(menuButton, "addEventListener")
      const documentSpy = jest.spyOn(document, "addEventListener")
      const closeSpy = jest.spyOn(closeButton, "addEventListener")

      controller.disconnect()
      controller.connect()

      expect(buttonSpy).toHaveBeenCalledWith("click", controller.handleButtonClick)
      expect(documentSpy).toHaveBeenCalledWith("keydown", controller.handleKeydown)
      expect(closeSpy).toHaveBeenCalledWith("click", controller.handleCloseButtonClick)
    })

    it("returns early when menu container is missing", async () => {
      document.body.innerHTML = `
        <button data-controller="main-menu" data-target="missing-menu"></button>
      `

      application.stop()
      application = Application.start()
      application.register("main-menu", MainMenuController)

      const missingButton = document.querySelector('[data-controller="main-menu"]')
      const missingController = await new Promise((resolve) => {
        setTimeout(() => {
          resolve(application.getControllerForElementAndIdentifier(missingButton, "main-menu"))
        }, 0)
      })

      expect(missingController.menuContainer).toBeNull()
      expect(() => missingController.disconnect()).not.toThrow()
    })
  })

  describe("openMenu", () => {
    it("enables focus guard and focuses the first element", () => {
      const focusableButton = makeFocusable(document.createElement("button"))
      focusableButton.textContent = "First"
      menuContainer.prepend(focusableButton)
      controller.openMenu()

      expect(window.focusGuard.trap).toHaveBeenCalledWith(menuContainer, menuButton)
      expect(document.activeElement).toBe(focusableButton)
    })
  })

  describe("closeMenu", () => {
    it("disables focus guard when available", () => {
      controller.openMenu()
      controller.closeMenu()

      expect(window.focusGuard.disable).toHaveBeenCalled()
    })
  })

  describe("handleButtonClick", () => {
    it("opens the menu after the delay and scrolls to top", () => {
      jest.useFakeTimers()
      document.body.style.overflow = "scroll"

      controller.handleButtonClick()
      jest.advanceTimersByTime(50)

      expect(menuButton.getAttribute("aria-expanded")).toBe("true")
      expect(menuContainer.getAttribute("aria-hidden")).toBe("false")
      expect(document.body.style.overflow).toBe("hidden")
      expect(window.scrollTo).toHaveBeenCalledWith({ top: 0, behavior: "smooth" })
    })

    it("does nothing when menu is already open", () => {
      jest.useFakeTimers()
      controller.openMenu()

      controller.handleButtonClick()
      jest.advanceTimersByTime(50)

      expect(window.scrollTo).not.toHaveBeenCalled()
      expect(menuContainer.getAttribute("aria-hidden")).toBe("false")
    })
  })

  describe("handleKeydown", () => {
    it("closes the menu on Escape", () => {
      document.body.style.overflow = "scroll"
      controller.openMenu()

      controller.handleKeydown({ key: "Escape" })

      expect(menuButton.getAttribute("aria-expanded")).toBe("false")
      expect(menuContainer.getAttribute("aria-hidden")).toBe("true")
      expect(document.body.style.overflow).toBe("scroll")
    })

    it("ignores non-escape keys", () => {
      controller.openMenu()

      controller.handleKeydown({ key: "Enter" })

      expect(menuContainer.getAttribute("aria-hidden")).toBe("false")
    })

    it("traps focus on Tab from the last focusable element", () => {
      const firstButton = makeFocusable(document.createElement("button"))
      firstButton.textContent = "First"
      const lastButton = makeFocusable(document.createElement("button"))
      lastButton.textContent = "Last"
      menuContainer.append(firstButton, lastButton)
      controller.openMenu()
      lastButton.focus()

      const event = { key: "Tab", shiftKey: false, preventDefault: jest.fn() }
      controller.handleKeydown(event)

      expect(event.preventDefault).toHaveBeenCalled()
      expect(document.activeElement).toBe(firstButton)
    })

    it("traps focus on Shift+Tab from the first focusable element", () => {
      const firstButton = makeFocusable(document.createElement("button"))
      firstButton.textContent = "First"
      const lastButton = makeFocusable(document.createElement("button"))
      lastButton.textContent = "Last"
      menuContainer.append(firstButton, lastButton)
      controller.openMenu()
      firstButton.focus()

      const event = { key: "Tab", shiftKey: true, preventDefault: jest.fn() }
      controller.handleKeydown(event)

      expect(event.preventDefault).toHaveBeenCalled()
      expect(document.activeElement).toBe(lastButton)
    })
  })

  describe("handleContainerClick", () => {
    it("closes the menu when clicking the container", () => {
      controller.openMenu()

      controller.handleContainerClick({ target: menuContainer })

      expect(menuContainer.getAttribute("aria-hidden")).toBe("true")
    })

    it("does not close the menu when clicking inside the container", () => {
      const childItem = document.getElementById("main-menu-item")
      controller.openMenu()

      controller.handleContainerClick({ target: childItem })

      expect(menuContainer.getAttribute("aria-hidden")).toBe("false")
    })
  })

  describe("handleCloseButtonClick", () => {
    it("closes the menu when open", () => {
      controller.openMenu()

      controller.handleCloseButtonClick()

      expect(menuContainer.getAttribute("aria-hidden")).toBe("true")
    })
  })

  describe("disconnect", () => {
    it("removes listeners and closes the menu if open", () => {
      const buttonSpy = jest.spyOn(menuButton, "removeEventListener")
      const documentSpy = jest.spyOn(document, "removeEventListener")
      const closeSpy = jest.spyOn(closeButton, "removeEventListener")

      document.body.style.overflow = "scroll"
      controller.openMenu()
      controller.disconnect()

      expect(buttonSpy).toHaveBeenCalledWith("click", controller.handleButtonClick)
      expect(documentSpy).toHaveBeenCalledWith("keydown", controller.handleKeydown)
      expect(closeSpy).toHaveBeenCalledWith("click", controller.handleCloseButtonClick)
      expect(menuContainer.getAttribute("aria-hidden")).toBe("true")
      expect(document.body.style.overflow).toBe("scroll")
    })
  })
})
