/* global jest */
import { Application } from "@hotwired/stimulus"
import HeaderAccountMobileController from "src/decidim/controllers/header_account_mobile/controller"

describe("HeaderAccountMobileController", () => {
  let application = null
  let controller = null
  let trigger = null
  let dropdown = null

  const buildDom = (withDropdown = true) => {
    let dropdownContainer = withDropdown
      ? '<div id="account-dropdown" aria-modal="false"></div>'
      : ""
    document.body.innerHTML = `
      <button data-controller="header-account-mobile" data-target="account-dropdown">
        Account
      </button>
      ${dropdownContainer}
    `
  }

  const startController = () => new Promise((resolve) => {
    setTimeout(() => {
      controller = application.getControllerForElementAndIdentifier(trigger, "header-account-mobile")
      resolve()
    }, 0)
  })

  beforeEach(() => {
    application = Application.start()
    application.register("header-account-mobile", HeaderAccountMobileController)

    buildDom()
    trigger = document.querySelector('[data-controller="header-account-mobile"]')
    dropdown = document.getElementById("account-dropdown")

    return startController()
  })

  afterEach(() => {
    application.stop()
    document.body.innerHTML = ""
    jest.restoreAllMocks()
  })

  describe("connect", () => {
    it("binds click event listener", () => {
      const spy = jest.spyOn(trigger, "addEventListener")

      controller.disconnect()
      controller.connect()

      expect(spy).toHaveBeenCalledWith("click", controller.handleClick)
    })
  })

  describe("handleClick", () => {
    it("sets aria-modal on the dropdown", () => {
      controller.handleClick()

      expect(dropdown.getAttribute("aria-modal")).toBe("true")
    })

    it("returns early when dropdown is missing", async () => {
      buildDom(false)
      trigger = document.querySelector('[data-controller="header-account-mobile"]')

      application.stop()
      application = Application.start()
      application.register("header-account-mobile", HeaderAccountMobileController)

      await startController()

      expect(() => controller.handleClick()).not.toThrow()
    })
  })

  describe("disconnect", () => {
    it("removes click event listener", () => {
      const spy = jest.spyOn(trigger, "removeEventListener")

      controller.disconnect()

      expect(spy).toHaveBeenCalledWith("click", controller.handleClick)
    })
  })
})
