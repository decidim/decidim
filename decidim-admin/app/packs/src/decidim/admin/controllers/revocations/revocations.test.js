/* global global, jest */

import { Application } from "@hotwired/stimulus"
import RevocationsController from "src/decidim/admin/controllers/revocations/controller"

global.fetch = jest.fn()

describe("RevocationsController", () => {
  let application = null

  // Mimics the markup rendered by the decidim/verifications/revocations cell,
  // with the text input the datepicker renders next to the submittable one.
  // The confirm and callout messages come pre-composed from the server.
  const optionHtml = (key, value, count) => `
    <label>
      <span>
        <input type="radio" name="revocations[impersonated_only]" value="${value}" data-revocations-option="${key}" data-confirm-message="Revoke ${count} ${key} verifications" data-callout-message="All ${count} ${key} verifications will be revoked" data-revocations-target="option" data-action="change->revocations#pick">
        <span>
          ${key}
          <span class="hidden" data-revocations-target="period"></span>
        </span>
        <span data-revocations-target="count" data-option="${key}" data-total="${count}">${count}</span>
        <span class="hidden" data-revocations-target="total">of ${count}</span>
      </span>
    </label>
  `

  const formHtml = (name, total, impersonated) => `
    <form data-controller="revocations" data-revocations="${name}" data-revocations-count-url-value="/admin/verifications/count">
      <input type="hidden" name="revocations[name]" value="${name}" data-revocations-target="name">
      ${optionHtml("total", false, total)}
      ${optionHtml("impersonated", true, impersonated)}
      <div data-revocations-date data-revocations-target="dateContainer" data-action="change->revocations#refresh selectDate->revocations#refresh">
        <input id="revocations_${name}_before_date_input" name="revocations[before_date]" type="date" data-revocations-target="date">
        <input id="revocations_${name}_before_date_input_date" type="text">
      </div>
      <div aria-live="polite">
        <div class="flash flex-col info hidden" data-revocations-target="callout" data-level="info"><div class="flash__message"></div></div>
        <div class="flash flex-col warning hidden" data-revocations-target="callout" data-level="warning"><div class="flash__message"></div></div>
      </div>
      <div class="hidden" data-revocations-bar data-revocations-target="bar">
        <button type="submit"
                data-confirm="Revoking cannot be undone"
                data-revocations-target="submit">Revoke</button>
      </div>
    </form>
  `

  // A successful count response as the server composes it for 15/03/2022.
  const countResponse = (overrides = {}) => ({
    ok: true,
    json: () => Promise.resolve({
      counts: { total: 4, impersonated: 2 },
      message: "Revoke 2 impersonated verifications before 15/03/2022",
      callout: { level: "info", message: "2 impersonated verifications before 15/03/2022 will be revoked" },
      period: "before 15/03/2022",
      ...overrides
    })
  })

  const flushPromises = () => new Promise((resolve) => setTimeout(resolve, 0))

  const form = (name) => document.querySelector(`[data-revocations='${name}']`)
  const submit = (name) => form(name).querySelector("[type='submit']")
  const radio = (name, option) => form(name).querySelector(`[data-revocations-option='${option}']`)
  const bar = (name) => form(name).querySelector("[data-revocations-bar]")
  const hiddenDate = (name) => form(name).querySelector("input[name='revocations[before_date]']")
  const visibleDate = (name) => document.getElementById(`revocations_${name}_before_date_input_date`)

  // What an option card shows, skipping its hidden parts: "[period] count [of total]".
  const cardText = (name, option) => Array.from(
    radio(name, option).closest("label").querySelectorAll("span[data-revocations-target]:not(.hidden)"),
    (element) => element.textContent
  ).join(" ")

  // The visible callouts of a form, as "level: message".
  const callouts = (name) => Array.from(
    form(name).querySelectorAll("[data-revocations-target='callout']:not(.hidden)"),
    (element) => `${element.dataset.level}: ${element.querySelector(".flash__message").textContent}`
  )

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
    document.body.innerHTML = formHtml("dummy", 5, 3) + formHtml("other", 3, 1)

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
    document.body.innerHTML = formHtml("dummy", 5, 3)
    radio("dummy", "total").checked = true
    hiddenDate("dummy").value = "2022-03-15"
    visibleDate("dummy").value = "15/03/2022"
    bar("dummy").classList.remove("hidden")
    form("dummy").querySelector("[data-level='info']").classList.remove("hidden")
    form("dummy").querySelector("[data-option='total']").textContent = "4"

    application = Application.start()
    application.register("revocations", RevocationsController)
    await flushPromises()

    expect(radio("dummy", "total").checked).toBe(false)
    expect(bar("dummy").classList.contains("hidden")).toBe(true)
    expect(hiddenDate("dummy").value).toEqual("")
    expect(visibleDate("dummy").value).toEqual("")
    expect(callouts("dummy")).toEqual([])
    expect(cardText("dummy", "total")).toEqual("5")
  })

  it("reveals the actions bar and the dateless confirm and callout of the picked option", () => {
    pick("dummy", "total")

    expect(bar("dummy").classList.contains("hidden")).toBe(false)
    expect(submit("dummy").dataset.confirm).toEqual("Revoke 5 total verifications")
    expect(callouts("dummy")).toEqual(["info: All 5 total verifications will be revoked"])
    expect(cardText("dummy", "total")).toEqual("5")
    expect(fetch).not.toHaveBeenCalled()
  })

  it("resets a form with its counts and callouts when an option is picked on a sibling one", async () => {
    fetch.mockResolvedValue(countResponse())
    pick("dummy", "total")
    typeDate("dummy", "2022-03-15", "15/03/2022")
    await flushPromises()

    pick("other", "impersonated")

    expect(radio("dummy", "total").checked).toBe(false)
    expect(bar("dummy").classList.contains("hidden")).toBe(true)
    expect(submit("dummy").dataset.confirm).toEqual("Revoking cannot be undone")
    expect(hiddenDate("dummy").value).toEqual("")
    expect(visibleDate("dummy").value).toEqual("")
    expect(callouts("dummy")).toEqual([])
    expect(cardText("dummy", "total")).toEqual("5")
    expect(cardText("dummy", "impersonated")).toEqual("3")
    expect(bar("other").classList.contains("hidden")).toBe(false)
    expect(submit("other").dataset.confirm).toEqual("Revoke 1 impersonated verifications")
    expect(callouts("other")).toEqual(["info: All 1 impersonated verifications will be revoked"])
  })

  it("asks the server about the picked option and date and shows its answer on both cards", async () => {
    fetch.mockResolvedValue(countResponse())

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
    expect(submit("dummy").dataset.confirm).toEqual("Revoke 2 impersonated verifications before 15/03/2022")
    expect(submit("dummy").disabled).toBe(false)
    expect(callouts("dummy")).toEqual(["info: 2 impersonated verifications before 15/03/2022 will be revoked"])
    expect(cardText("dummy", "total")).toEqual("before 15/03/2022 4 of 5")
    expect(cardText("dummy", "impersonated")).toEqual("before 15/03/2022 2 of 3")
  })

  it("warns and holds the submission when nothing matches the picked option and date", async () => {
    fetch.mockResolvedValue(countResponse({
      counts: { total: 3, impersonated: 0 },
      message: "Revoke 0 impersonated verifications before 01/01/2019",
      callout: { level: "warning", message: "No impersonated verifications before 01/01/2019" },
      period: "before 01/01/2019"
    }))

    pick("dummy", "impersonated")
    typeDate("dummy", "2019-01-01", "01/01/2019")
    await flushPromises()

    expect(submit("dummy").dataset.confirm).toEqual("Revoke 0 impersonated verifications before 01/01/2019")
    expect(submit("dummy").disabled).toBe(true)
    expect(callouts("dummy")).toEqual(["warning: No impersonated verifications before 01/01/2019"])
    expect(cardText("dummy", "impersonated")).toEqual("before 01/01/2019 0 of 3")
  })

  it("stops listening for sibling picks when disconnected", () => {
    const removeSpy = jest.spyOn(document, "removeEventListener")
    const controller = application.getControllerForElementAndIdentifier(form("dummy"), "revocations")

    controller.disconnect()

    expect(removeSpy).toHaveBeenCalledWith("revocations:picked", controller.onSiblingPicked)
    removeSpy.mockRestore()
  })

  it("discards outdated responses", async () => {
    let resolveFetch = null
    fetch.mockReturnValue(new Promise((resolve) => {
      resolveFetch = resolve
    }))

    pick("dummy", "impersonated")
    typeDate("dummy", "2022-03-15", "15/03/2022")

    // The user picks another option while the request is still in flight.
    radio("dummy", "total").checked = true
    resolveFetch(countResponse())
    await flushPromises()

    expect(submit("dummy").dataset.confirm).toEqual("Revoking cannot be undone")
    expect(callouts("dummy")).toEqual([])
    expect(cardText("dummy", "impersonated")).toEqual("3")
  })

  it("holds the submission with the generic confirm and no callout while the message is being fetched", async () => {
    let rejectFirst = null
    fetch.mockReturnValueOnce(new Promise((_resolve, reject) => {
      rejectFirst = reject
    })).mockReturnValue(new Promise(() => {}))
    const errorSpy = jest.spyOn(console, "error").mockImplementation(() => {})

    pick("dummy", "total")
    typeDate("dummy", "2022-03-15", "15/03/2022")
    // An outdated request fails while the next one is pending.
    typeDate("dummy", "2022-01-01", "01/01/2022")
    rejectFirst(new Error("network down"))
    await flushPromises()

    expect(submit("dummy").dataset.confirm).toEqual("Revoking cannot be undone")
    expect(submit("dummy").disabled).toBe(true)
    expect(callouts("dummy")).toEqual([])
    errorSpy.mockRestore()
  })

  it("falls back to the dateless message and callout synchronously when the date is cleared", () => {
    fetch.mockReturnValue(new Promise(() => {}))

    pick("dummy", "total")
    typeDate("dummy", "2022-03-15", "15/03/2022")
    typeDate("dummy", "", "")

    expect(submit("dummy").dataset.confirm).toEqual("Revoke 5 total verifications")
    expect(submit("dummy").disabled).toBe(false)
    expect(callouts("dummy")).toEqual(["info: All 5 total verifications will be revoked"])
    expect(fetch).toHaveBeenCalledTimes(1)
  })

  it("keeps the generic confirm and no callout when the server rejects the filters", async () => {
    fetch.mockResolvedValue({ ok: false, status: 422, json: () => Promise.resolve({ error: "invalid" }) })
    const errorSpy = jest.spyOn(console, "error").mockImplementation(() => {})

    pick("dummy", "total")
    typeDate("dummy", "2022-03-15", "15/03/2022")
    await flushPromises()

    expect(submit("dummy").dataset.confirm).toEqual("Revoking cannot be undone")
    expect(submit("dummy").disabled).toBe(false)
    expect(callouts("dummy")).toEqual([])
    errorSpy.mockRestore()
  })

  it("logs fetch errors and keeps the generic confirm, the totals and no callout", async () => {
    fetch.mockResolvedValueOnce(countResponse()).mockRejectedValueOnce(new Error("network down"))
    const errorSpy = jest.spyOn(console, "error").mockImplementation(() => {})

    pick("dummy", "total")
    typeDate("dummy", "2022-03-15", "15/03/2022")
    await flushPromises()
    // The answer for the first date must not linger once a later request fails.
    typeDate("dummy", "2022-01-01", "01/01/2022")
    await flushPromises()

    expect(errorSpy).toHaveBeenCalledWith("Error fetching authorizations count:", expect.any(Error))
    expect(submit("dummy").dataset.confirm).toEqual("Revoking cannot be undone")
    expect(submit("dummy").disabled).toBe(false)
    expect(callouts("dummy")).toEqual([])
    expect(cardText("dummy", "total")).toEqual("5")
    expect(cardText("dummy", "impersonated")).toEqual("3")
    errorSpy.mockRestore()
  })
})
