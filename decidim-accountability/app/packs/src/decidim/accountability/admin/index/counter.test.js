import Counter from "src/decidim/accountability/admin/index/counter"

describe("Counter", () => {
  afterEach(() => {
    document.body.innerHTML = ""
  })

  it("labels the selected result count", () => {
    document.body.innerHTML = `
      <input data-result-checkbox type="checkbox" checked>
      <input data-result-checkbox type="checkbox" checked>
      <span data-selected-count data-selected-label="selected"></span>
    `

    const counter = new Counter();
    counter.init();

    expect(document.querySelector("[data-selected-count]").textContent).toBe("(2 selected)")
  })
})
