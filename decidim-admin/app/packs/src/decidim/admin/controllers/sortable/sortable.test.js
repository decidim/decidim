import { Application } from "@hotwired/stimulus"
import SortableController from "src/decidim/admin/controllers/sortable/controller"

describe("SortableController", () => {
  let application = null
  let element = null

  const waitForConnect = () =>
    new Promise((resolve) => {
      setTimeout(resolve, 0)
    })

  afterEach(() => {
    if (application) {
      application.stop()
    }
    document.body.innerHTML = ""
  })

  // The hidden id inputs interleaved between the list items mimic the markup
  // rendered by Rails' fields_for for persisted records.
  beforeEach(async () => {
    document.body.innerHTML = `
      <ul data-controller="sortable" data-action="sortupdate->sortable#update">
        <li id="item-a"><input class="position" value="1"></li>
        <input type="hidden" name="proposals[0][id]" value="10">
        <li id="item-b"><input class="position" value="2"></li>
        <input type="hidden" name="proposals[1][id]" value="20">
        <li id="item-c"><input class="position" value="3"></li>
        <input type="hidden" name="proposals[2][id]" value="30">
      </ul>
    `

    application = Application.start()
    application.register("sortable", SortableController)

    element = document.querySelector("[data-controller='sortable']")

    await waitForConnect()
  })

  it("renumbers the position inputs following the new list order", () => {
    // Move the last item before the first one.
    const items = element.querySelectorAll("li")
    element.insertBefore(items[2], items[0])

    element.dispatchEvent(new CustomEvent("sortupdate", { bubbles: true }))

    const positionOf = (id) => element.querySelector(`#${id} input.position`).value
    expect(positionOf("item-c")).toEqual("1")
    expect(positionOf("item-a")).toEqual("2")
    expect(positionOf("item-b")).toEqual("3")
  })
})
