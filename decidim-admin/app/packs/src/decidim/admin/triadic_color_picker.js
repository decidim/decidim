// This script is used to generate the triadic colors for the primary color
// picker. It is used in the organization settings page.
//
// It is based on the following article:
// https://css-tricks.com/converting-color-spaces-in-javascript/
//

const hslToHex = (hue, saturation, light) => {
  const lightness = light / 100;
  const adjustmentFactor = saturation * Math.min(lightness, 1 - lightness) / 100;
  const getColorComponent = (colorIndex) => {
    const colorWheelPosition = (colorIndex + hue / 30) % 12;
    const color = lightness - adjustmentFactor * Math.max(Math.min(colorWheelPosition - 3, 9 - colorWheelPosition, 1), -1);
    // convert to Hex and prefix "0" if needed
    return Math.round(255 * color).toString(16).padStart(2, "0");
  };
  return `#${getColorComponent(0)}${getColorComponent(8)}${getColorComponent(4)}`;
}

const hexToHsl = (hexColor) => {
  // Convert hex to RGB first
  let red = 0;
  let green = 0;
  let blue = 0;

  if (hexColor.length === 4) {
    red = `0x${hexColor[1]}${hexColor[1]}`;
    green = `0x${hexColor[2]}${hexColor[2]}`;
    blue = `0x${hexColor[3]}${hexColor[3]}`;
  } else if (hexColor.length === 7) {
    red = `0x${hexColor[1]}${hexColor[2]}`;
    green = `0x${hexColor[3]}${hexColor[4]}`;
    blue = `0x${hexColor[5]}${hexColor[6]}`;
  }
  // Then to HSL
  red /= 255;
  green /= 255;
  blue /= 255;

  let cmin = Math.min(red, green, blue);
  let cmax = Math.max(red, green, blue);
  let delta = cmax - cmin;
  let hue = 0;
  let saturation = 0;
  let lightness = 0;

  if (delta === 0) {
    hue = 0;
  }
  else if (cmax === red) {
    hue = ((green - blue) / delta) % 6;
  } else if (cmax === green) {
    hue = (blue - red) / delta + 2;}
  else {
    hue = (red - green) / delta + 4;
  }

  hue = Math.round(hue * 60);

  if (hue < 0) {
    hue += 360;
  }

  lightness = (cmax + cmin) / 2;
  if (delta === 0) {
    saturation = 0
  } else {
    saturation = delta / (1 - Math.abs(2 * lightness - 1))
  };
  saturation = Number((saturation * 100).toFixed(1));
  lightness = Number((lightness * 100).toFixed(1));

  return { hue, saturation, lightness };
}

const generateHslaColors = (saturation, lightness, amount = 360) => {
  const huedelta = Math.trunc(360 / amount)
  return Array.from({ length: amount }, (_array, index) => ({ hue: index * huedelta, saturation, lightness }))
}

const setTheme = (primary, saturation) => {
  // Lightness parameter is not used, the default is auto-calculated
  const { hue, saturation: defaultS, lightness } = hexToHsl(primary);

  const secondary = hslToHex(hue + 120, saturation || defaultS, lightness);
  const tertiary = hslToHex(hue - 120, saturation || defaultS, lightness);

  document.documentElement.style.setProperty("--primary", primary);
  document.documentElement.style.setProperty("--secondary", secondary);
  document.documentElement.style.setProperty("--tertiary", tertiary);
  document.getElementById("preview-primary").value = primary;
  document.getElementById("preview-secondary").value = secondary;
  (document.getElementById("preview-tertiary") || {}).value = tertiary;
}

document.addEventListener("DOMContentLoaded", () => {
  const selector = document.querySelector("#primary-selector")

  if (selector) {
    const primary = document.querySelector("#preview-primary")
    const primarySaturation = document.querySelector("#primary-saturation")
    const updateButton = document.querySelector("#set-colors")

    generateHslaColors(50, 50).forEach((color) => {
      const div = document.createElement("div")
      const hex = hslToHex(color.hue, color.saturation, color.lightness)
      div.style.backgroundColor = hex
      div.dataset.value = hex
      div.style.flex = 1
      selector.appendChild(div)
    })

    // Use the previous primary and secondary colors as the default selection
    document.documentElement.style.setProperty("--primary", document.querySelector("#organization_primary_color").value);
    document.documentElement.style.setProperty("--secondary", document.querySelector("#organization_secondary_color").value);
    document.documentElement.style.setProperty("--tertiary", document.querySelector("#organization_tertiary_color").value);

    selector.addEventListener("click", ({ target: { dataset: { value }}}) => setTheme(value, Number(primarySaturation.value)));
    primarySaturation.addEventListener("input", ({ target: { value }}) => setTheme(primary.value, Number(value)));
    updateButton.addEventListener("click", (event) => {
      event.preventDefault()

      document.querySelector("#organization_primary_color").value = document.querySelector("#preview-primary").value
      document.querySelector("#organization_secondary_color").value = document.querySelector("#preview-secondary").value
      document.querySelector("#organization_tertiary_color").value = document.querySelector("#preview-tertiary").value
    });
  }
})
