const designTokens = require("./tailwind")

describe("Design System Tailwind tokens", () => {
  it("maps the semantic colors", () => {
    expect(designTokens.colors.primary).toEqual("#e02d2d")
    expect(designTokens.colors.secondary).toEqual("#155abf")
    expect(designTokens.colors.neutral[500]).toEqual("#737373")
  })

  it("maps the typography tokens", () => {
    expect(designTokens.fontSize.md).toEqual(["16px", "24px"])
    expect(designTokens.fontSize["5xl"]).toEqual(["48px", "48px"])
  })

  it("maps the measure tokens", () => {
    expect(designTokens.lineHeight.md).toEqual("24px")
    expect(designTokens.spacing.md).toEqual("16px")
    expect(designTokens.borderRadius.full).toEqual("1000px")
    expect(designTokens.borderWidth.md).toEqual("4px")
    expect(designTokens.opacity.disabled).toEqual("40%")
    expect(designTokens.screens.xs).toEqual("375px")
  })

  it("maps the shadow tokens", () => {
    expect(designTokens.boxShadow.DEFAULT).toEqual("var(--shadow-focus-default)")
  })
})
