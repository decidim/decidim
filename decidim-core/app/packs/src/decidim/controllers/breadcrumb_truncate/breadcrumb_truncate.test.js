/* global jest */
import { Application } from "@hotwired/stimulus"
import BreadcrumbTruncateController from "src/decidim/controllers/breadcrumb_truncate/controller"

describe("BreadcrumbTruncateController", () => {
  let application = null
  let controller = null
  let element = null
  let textElement = null
  let resizeObserverMock = null

  const startController = () => new Promise((resolve) => {
    setTimeout(() => {
      controller = application.getControllerForElementAndIdentifier(element, "breadcrumb-truncate")
      resolve()
    }, 0)
  })

  beforeEach(() => {
    resizeObserverMock = {
      observe: jest.fn(),
      disconnect: jest.fn()
    }

    window.ResizeObserver = jest.fn().mockImplementation(() => resizeObserverMock)

    document.body.innerHTML = `
      <span data-controller="breadcrumb-truncate" class="truncate">
        <span data-breadcrumb-truncate-target="text">Very long participatory space title example</span>
      </span>
    `

    application = Application.start()
    application.register("breadcrumb-truncate", BreadcrumbTruncateController)

    element = document.querySelector('[data-controller="breadcrumb-truncate"]')
    textElement = element.querySelector('[data-breadcrumb-truncate-target="text"]')

    return startController()
  })

  afterEach(() => {
    application.stop()
    document.body.innerHTML = ""
    jest.restoreAllMocks()
  })

  it("keeps the full text when it fits", () => {
    Reflect.defineProperty(element, "clientWidth", { configurable: true, value: 100 })
    Reflect.defineProperty(element, "scrollWidth", { configurable: true, get: () => 80 })

    controller.refresh()

    expect(textElement.textContent).toBe("Very long participatory space title example")
    expect(element.hasAttribute("title")).toBe(false)
  })

  it("truncates at the last fitting word and adds an ellipsis", () => {
    Reflect.defineProperty(element, "clientWidth", { configurable: true, value: 100 })
    Reflect.defineProperty(element, "scrollWidth", {
      configurable: true,
      get: () => (textElement.textContent.length > 16
        ? 120
        : 80)
    })

    controller.refresh()

    expect(textElement.textContent).toBe("Very long...")
    expect(element.getAttribute("title")).toBe("Very long participatory space title example")
  })

  it("falls back to character truncation for a single long word", () => {
    textElement.textContent = "Supercalifragilisticexpialidocious"
    controller.originalTexts = [textElement.textContent]

    Reflect.defineProperty(element, "clientWidth", { configurable: true, value: 100 })
    Reflect.defineProperty(element, "scrollWidth", {
      configurable: true,
      get: () => (textElement.textContent.length > 9
        ? 120
        : 80)
    })

    controller.refresh()

    expect(textElement.textContent).toBe("Superc...")
  })

  it("disconnects the resize observer", () => {
    controller.disconnect()

    expect(resizeObserverMock.disconnect).toHaveBeenCalled()
  })

  it("prioritizes truncating the widest item in group mode", async () => {
    document.body.innerHTML = `
      <nav data-controller="breadcrumb-truncate">
        <span data-breadcrumb-truncate-target="item">
          <span data-breadcrumb-truncate-target="text">Very long participatory space title example</span>
        </span>
        <span data-breadcrumb-truncate-target="item">
          <span data-breadcrumb-truncate-target="text">Proposals</span>
        </span>
      </nav>
    `

    application.stop()
    application = Application.start()
    application.register("breadcrumb-truncate", BreadcrumbTruncateController)

    element = document.querySelector('[data-controller="breadcrumb-truncate"]')
    const itemElements = element.querySelectorAll('[data-breadcrumb-truncate-target="item"]')
    const textElements = element.querySelectorAll('[data-breadcrumb-truncate-target="text"]')

    Reflect.defineProperty(element, "clientWidth", { configurable: true, value: 100 })
    Reflect.defineProperty(element, "scrollWidth", { configurable: true, value: 200 })
    Reflect.defineProperty(itemElements[0], "scrollWidth", { configurable: true, value: 150 })
    Reflect.defineProperty(itemElements[1], "scrollWidth", { configurable: true, value: 50 })
    Reflect.defineProperty(itemElements[0], "clientWidth", {
      configurable: true,
      get: () => Number.parseInt(itemElements[0].style.maxWidth || "150", 10)
    })
    Reflect.defineProperty(itemElements[1], "clientWidth", {
      configurable: true,
      get: () => Number.parseInt(itemElements[1].style.maxWidth || "50", 10)
    })
    Reflect.defineProperty(itemElements[0], "scrollWidth", {
      configurable: true,
      get: () => (textElements[0].textContent.length > 16
        ? 120
        : 80)
    })
    Reflect.defineProperty(itemElements[1], "scrollWidth", {
      configurable: true,
      get: () => 50
    })

    await startController()
    controller.refresh()

    expect(textElements[0].textContent).not.toBe("Very long participatory space title example")
    expect(textElements[0].textContent.endsWith("...")).toBe(true)
    expect(textElements[1].textContent).toBe("Proposals")
  })
})
