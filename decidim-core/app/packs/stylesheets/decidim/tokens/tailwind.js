/* eslint-disable no-sync, no-undef */
// The Design System exports colors and shadows as JavaScript values, but the
// measures are only available as CSS custom properties. This adapter exposes
// all of them as Tailwind theme values without duplicating the token values.
const fs = require("fs")
const path = require("path")

const generatedTokens = require("./tailwind-variables")

const readVariables = (filename) => {
  const contents = fs.readFileSync(path.join(__dirname, filename), "utf8")
  const variables = {}

  for (const declaration of contents.matchAll(/--([\w-]+):\s*([^;]+);/g)) {
    variables[declaration[1]] = declaration[2].trim()
  }

  return variables
}

const measures = readVariables("measures.css")

const measure = (name) => {
  if (!(name in measures)) {
    throw new Error(`Missing Design System token: --${name}`)
  }

  return measures[name]
}

const color = (name) => generatedTokens.colors.color[name]
const palette = (name) => generatedTokens.colors[`color-${name}`]

const spacingSizes = ["2xs", "xs", "sm", "md", "lg", "xl", "2xl", "3xl", "4xl", "5xl"]
const fontSizeSizes = ["xs", "sm", "md", "lg", "xl", "2xl", "3xl", "4xl", "5xl"]
const borderRadiusSizes = ["none", "xs", "sm", "md", "lg", "xl", "2xl", "3xl", "4xl", "full"]
const borderWidthSizes = ["xs", "sm", "md"]
const breakpointSizes = ["xs", "sm", "md", "lg", "xl", "2xl"]

const {
  default: focusShadow,
  outside: focusOutsideShadow,
  ...boxShadowTokens
} = generatedTokens.boxShadow

module.exports = {
  colors: {
    white: color("white"),
    black: color("black"),
    primary: color("primary"),
    secondary: color("secondary"),
    tertiary: color("tertiary"),
    success: color("success"),
    alert: color("alert"),
    warning: color("warning"),
    info: color("info"),
    blue: palette("blue"),
    red: palette("red"),
    yellow: palette("yellow"),
    green: palette("green"),
    purple: palette("purple"),
    neutral: palette("neutral"),
    slate: palette("slate"),
    alpha: {
      white: generatedTokens.colors["color-alphas-white"]
    }
  },
  boxShadow: {
    ...boxShadowTokens,
    focus: focusShadow,
    "focus-outside": focusOutsideShadow
  },
  fontSize: Object.fromEntries(
    fontSizeSizes.map((size) => [
      size,
      [
        measure(`measure-font-size-typography-fontsize-${size}`),
        measure(`measure-line-height-typography-lineheight-${size}`)
      ]
    ])
  ),
  lineHeight: Object.fromEntries(
    fontSizeSizes.map((size) => [size, measure(`measure-line-height-typography-lineheight-${size}`)])
  ),
  spacing: Object.fromEntries(
    spacingSizes.map((size) => [size, measure(`measure-space-space-${size}`)])
  ),
  borderRadius: Object.fromEntries(
    borderRadiusSizes.map((size) => [size, measure(`measure-border-radius-border-radius-${size}`)])
  ),
  borderWidth: Object.fromEntries(
    borderWidthSizes.map((size) => [size, measure(`measure-border-width-border-width-${size}`)])
  ),
  opacity: {
    disabled: measure("measure-opacity-color-opacity-40")
  },
  screens: Object.fromEntries(
    breakpointSizes.map((size) => [size, measure(`measure-size-breakpoint-${size}`)])
  ),
  containerPadding: {
    DEFAULT: measure("measure-space-space-md"),
    lg: measure("measure-space-space-4xl")
  },
  maxWidth: {
    content: measure("measure-size-range-maxwidth")
  }
}
