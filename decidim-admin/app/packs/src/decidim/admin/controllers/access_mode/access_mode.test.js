/* global jest */

import { Application } from "@hotwired/stimulus"
import AccessModeController from "src/decidim/admin/controllers/access_mode/controller"

describe("AccessModeController", () => {
  let application = null
  let controller = null
  let element = null
  let checkbox = null
  let accessModeFieldset = null

  beforeEach(async () => {
    document.body.innerHTML = `
      <div data-controller="access-mode">
        <div id="has_members">
          <input type="hidden" name="has_members" value="0">
          <input type="checkbox" id="has_members_checkbox" name="has_members" value="1">
        </div>
        <fieldset id="access_mode">
          <legend>Access mode</legend>
          <label>Open<input type="radio" name="access_mode" value="open"></label>
        </fieldset>
      </div>
    `

    application = Application.start()
    application.register("access-mode", AccessModeController)

    element = document.querySelector("[data-controller='access-mode']")
    checkbox = element.querySelector("#has_members input[type='checkbox']")
    accessModeFieldset = element.querySelector("#access_mode")

    await new Promise((resolve) => {
      setTimeout(() => {
        controller = application.getControllerForElementAndIdentifier(element, "access-mode")
        resolve()
      }, 0)
    })
  })

  afterEach(() => {
    controller.disconnect()
    application.stop()
    document.body.innerHTML = ""
  })

  it("hides the access_mode fieldset when members checkbox is unchecked", () => {
    expect(accessModeFieldset.hidden).toBe(true)
    expect(accessModeFieldset.style.display).toBe("none")
  })

  it("shows the fieldset when the members checkbox becomes checked", () => {
    checkbox.checked = true
    checkbox.dispatchEvent(new Event("change"))

    expect(accessModeFieldset.hidden).toBe(false)
    expect(accessModeFieldset.style.display).toBe("")
  })

  it("removes the event listener on disconnect", () => {
    const removeSpy = jest.spyOn(checkbox, "removeEventListener")

    controller.disconnect()

    expect(removeSpy).toHaveBeenCalledWith("change", controller.toggleAccessMode)
  })
})
