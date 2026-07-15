/* global global, jest */

import { Application } from "@hotwired/stimulus"
import RevocationsController from "src/decidim/admin/controllers/revocations/controller"

global.fetch = jest.fn()

describe("RevocationsController", () => {
  let application = null

  // Mimics the markup rendered by the decidim/verifications/revocations cell,
  // with the text input the datepicker renders next to the submittable one.
  const formHtml = (name, totalCount, impersonatedCount) => `
    <form data-controller="revocations" data-revocations="${name}" data-revocations-count-url-value="/admin/verifications/count">
      <input type="hidden" name="revocations[name]" value="${name}" data-revocations-target="name">
      <label>
        <input type="radio" name="revocations[impersonated_only]" value="false" data-revocations-option="total" data-count="${totalCount}" data-revocations-target="option" data-action="change->revocations#pick">
      </label>
      <label>
        <input type="radio" name="revocations[impersonated_only]" value="true" data-revocations-option="impersonated" data-count="${impersonatedCount}" data-revocations-target="option" data-action="change->revocations#pick">
      </label>
      <div data-revocations-date data-revocations-target="dateContainer" data-action="change->revocations#refresh selectDate->revocations#refresh">
        <input id="revocations_${name}_before_date_input" name="revocations[before_date]" type="date">
        <input id="revocations_${name}_before_date_input_date" type="text">
      </div>
      <div class="hidden" data-revocations-bar data-revocations-target="bar">
        <button type="submit"
                data-confirm="Revoking cannot be undone"
                data-confirm-total="Revoke %{count} authorizations"
                data-confirm-impersonated="Revoke %{count} impersonated"
                data-confirm-total-before-date="Revoke %{count} authorizations before %{date}"
                data-confirm-impersonated-before-date="Revoke %{count} impersonated before %{date}"
                data-revocations-target="submit">Revoke</button>
      </div>
    </form>
  `

  const flushPromises = () => new Promise((resolve) => setTimeout(resolve, 0))

  const form = (name) => document.querySelector(`[data-revocations='${name}']`)
  const submit = (name) => form(name).querySelector("[type='submit']")
  const radio = (name, option) => form(name).querySelector(`[data-revocations-option='${option}']`)
  const bar = (name) => form(name).querySelector("[data-revocations-bar]")
  const hiddenDate = (name) => form(name).querySelector("input[name='revocations[before_date]']")
  const visibleDate = (name) => document.getElementById(`revocations_${name}_before_date_input_date`)

  const pick = (name, option) => {
    const input = radio(name, option)
    input.checked = true
    input.dispatchEvent(new Event("change", { bubbles: true }))
  }

  const typeDate = (name, submittable, displayed) => {
    hiddenDate(name).value = submittable
    visibleDate(name).value = displayed
    hiddenDate(name).dispatchEvent(new Event("change", { bubbles: true }))
  }

  beforeEach(async () => {
    fetch.mockReset()
    document.body.innerHTML = formHtml("dummy", 5, 2) + formHtml("other", 3, 1)

    application = Application.start()
    application.register("revocations", RevocationsController)

    await flushPromises()
  })

  afterEach(() => {
    application.stop()
    document.body.innerHTML = ""
  })

  it("starts with every form reset", async () => {
    application.stop()
    document.body.innerHTML = formHtml("dummy", 5, 2)
    radio("dummy", "total").checked = true
    hiddenDate("dummy").value = "2022-03-15"
    visibleDate("dummy").value = "15/03/2022"
    bar("dummy").classList.remove("hidden")

    application = Application.start()
    application.register("revocations", RevocationsController)
    await flushPromises()

    expect(radio("dummy", "total").checked).toBe(false)
    expect(bar("dummy").classList.contains("hidden")).toBe(true)
    expect(hiddenDate("dummy").value).toEqual("")
    expect(visibleDate("dummy").value).toEqual("")
  })

  it("reveals the actions bar and writes the confirm text from the radio count", () => {
    pick("dummy", "total")

    expect(bar("dummy").classList.contains("hidden")).toBe(false)
    expect(submit("dummy").dataset.confirm).toEqual("Revoke 5 authorizations")
    expect(fetch).not.toHaveBeenCalled()
  })

  it("resets a form when an option is picked on a sibling one", () => {
    pick("dummy", "total")
    hiddenDate("dummy").value = "2022-03-15"
    visibleDate("dummy").value = "15/03/2022"

    pick("other", "impersonated")

    expect(radio("dummy", "total").checked).toBe(false)
    expect(bar("dummy").classList.contains("hidden")).toBe(true)
    expect(hiddenDate("dummy").value).toEqual("")
    expect(visibleDate("dummy").value).toEqual("")
    expect(bar("other").classList.contains("hidden")).toBe(false)
    expect(submit("other").dataset.confirm).toEqual("Revoke 1 impersonated")
  })

  it("asks the server for the count matching the picked option and date", async () => {
    fetch.mockResolvedValue({ json: () => Promise.resolve({ count: 3 }) })

    pick("dummy", "impersonated")
    hiddenDate("dummy").value = "2022-03-15"
    visibleDate("dummy").value = "15/03/2022"
    visibleDate("dummy").dispatchEvent(new CustomEvent("selectDate", { bubbles: true }))
    await flushPromises()

    const [requestedUrl, options] = fetch.mock.calls[0]
    expect(requestedUrl).toContain("/admin/verifications/count?")
    expect(requestedUrl).toContain("revocations%5Bname%5D=dummy")
    expect(requestedUrl).toContain("revocations%5Bimpersonated_only%5D=true")
    expect(requestedUrl).toContain("revocations%5Bbefore_date%5D=2022-03-15")
    expect(options).toMatchObject({
      credentials: "same-origin",
      headers: { "Accept": "application/json", "X-Requested-With": "XMLHttpRequest" }
    })
    expect(submit("dummy").dataset.confirm).toEqual("Revoke 3 impersonated before 15/03/2022")
    expect(submit("dummy").disabled).toBe(false)
  })

  it("writes a zero count when no authorization matches the picked date", async () => {
    fetch.mockResolvedValue({ json: () => Promise.resolve({ count: 0 }) })

    pick("dummy", "total")
    typeDate("dummy", "2019-01-01", "01/01/2019")
    await flushPromises()

    expect(submit("dummy").dataset.confirm).toEqual("Revoke 0 authorizations before 01/01/2019")
  })

  it("stops listening for sibling picks when disconnected", () => {
    const removeSpy = jest.spyOn(document, "removeEventListener")
    const controller = application.getControllerForElementAndIdentifier(form("dummy"), "revocations")

    controller.disconnect()

    expect(removeSpy).toHaveBeenCalledWith("revocations:picked", controller.onSiblingPicked)
    removeSpy.mockRestore()
  })

  it("discards responses the form has already moved on from", async () => {
    let resolveFetch = null
    fetch.mockReturnValue(new Promise((resolve) => {
      resolveFetch = resolve
    }))

    pick("dummy", "impersonated")
    typeDate("dummy", "2022-03-15", "15/03/2022")

    // The user picks another option while the request is still in flight.
    radio("dummy", "total").checked = true
    resolveFetch({ json: () => Promise.resolve({ count: 9 }) })
    await flushPromises()

    expect(submit("dummy").dataset.confirm).toEqual("Revoking cannot be undone")
  })

  it("holds the submission with the generic confirm while the count is being fetched", () => {
    fetch.mockReturnValue(new Promise(() => {}))

    pick("dummy", "total")
    typeDate("dummy", "2022-03-15", "15/03/2022")

    expect(submit("dummy").dataset.confirm).toEqual("Revoking cannot be undone")
    expect(submit("dummy").disabled).toBe(true)
  })

  it("falls back to the dateless template synchronously when the date is cleared", () => {
    fetch.mockReturnValue(new Promise(() => {}))

    pick("dummy", "total")
    typeDate("dummy", "2022-03-15", "15/03/2022")
    typeDate("dummy", "", "")

    expect(submit("dummy").dataset.confirm).toEqual("Revoke 5 authorizations")
    expect(fetch).toHaveBeenCalledTimes(1)
  })

  it("logs fetch errors and keeps the generic confirm", async () => {
    fetch.mockRejectedValue(new Error("network down"))
    const errorSpy = jest.spyOn(console, "error").mockImplementation(() => {})

    pick("dummy", "total")
    typeDate("dummy", "2022-03-15", "15/03/2022")
    await flushPromises()

    expect(errorSpy).toHaveBeenCalledWith("Error fetching authorizations count:", expect.any(Error))
    expect(submit("dummy").dataset.confirm).toEqual("Revoking cannot be undone")
    expect(submit("dummy").disabled).toBe(false)
    errorSpy.mockRestore()
  })
})
