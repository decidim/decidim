/* global jest */

import { datalistSelect } from "src/decidim/datalist_select"

describe("datalistSelect", () => {
  beforeEach(() => {
    document.body.innerHTML = `
      <div id="template-select">
        <input type="hidden" />
        <input type="text" />
        <datalist>
          <option data-value="42">Test: Use of special characters ?!-&amp;</option>
        </datalist>
      </div>
    `
  })

  it("selects an option whose label contains HTML-sensitive characters", () => {
    const target = document.querySelector("#template-select")
    const textInput = target.querySelector("input[type='text']")
    const hiddenInput = target.querySelector("input[type='hidden']")
    const callback = jest.fn()

    datalistSelect(target, callback)

    textInput.value = "Test: Use of special characters ?!-&"
    textInput.dispatchEvent(new Event("input"))

    expect(hiddenInput.value).toBe("42")
    expect(callback).toHaveBeenCalledWith("42")
  })
})
