/* eslint-disable */

function hslToHex(hue, saturation, lightness) {
  lightness /= 100;
  const a = saturation * Math.min(lightness, 1 - lightness) / 100;
  const f = (n) => {
    const k = (n + hue / 30) % 12;
    const color = lightness - a * Math.max(Math.min(k - 3, 9 - k, 1), -1);
    return Math.round(255 * color).toString(16).padStart(2, "0");// convert to Hex and prefix "0" if needed
  };
  return `#${f(0)}${f(8)}${f(4)}`;
}

function hexToHsl(hexColor) {
  // Convert hex to RGB first
  let b = 0,
      g = 0,
      r = 0;
  if (hexColor.length === 4) {
    r = `0x${hexColor[1]}${hexColor[1]}`;
    g = `0x${hexColor[2]}${hexColor[2]}`;
    b = `0x${hexColor[3]}${hexColor[3]}`;
  } else if (hexColor.length === 7) {
    r = `0x${hexColor[1]}${hexColor[2]}`;
    g = `0x${hexColor[3]}${hexColor[4]}`;
    b = `0x${hexColor[5]}${hexColor[6]}`;
  }
  // Then to HSL
  r /= 255;
  g /= 255;
  b /= 255;
  let cmin = Math.min(r, g, b),
      cmax = Math.max(r, g, b),
      delta = cmax - cmin,
      h = 0,
      s = 0,
      l = 0;

  if (delta == 0)
  {h = 0;}
  else if (cmax == r)
  {h = ((g - b) / delta) % 6;}
  else if (cmax == g)
  {h = (b - r) / delta + 2;}
  else
  {h = (r - g) / delta + 4;}

  h = Math.round(h * 60);

  if (h < 0)
  {h += 360;}

  l = (cmax + cmin) / 2;
  s = delta == 0
    ? 0
    : delta / (1 - Math.abs(2 * l - 1));
  s = Number((s * 100).toFixed(1));
  l = Number((l * 100).toFixed(1));

  return { h, s, l };
}

function generateHslaColors(saturation, lightness, amount = 360) {
  const huedelta = Math.trunc(360 / amount)
  return Array.from({ length: amount }, (_, i) => ({ hue: i * huedelta, saturation, lightness }))
}

function setTheme(primary, saturation) {
  // Lightness parameter is not used, the default is auto-calculated
  const { h, s: defaultS, l } = hexToHsl(primary);

  const secondary = hslToHex(h + 120, saturation || defaultS, l);
  const tertiary = hslToHex(h - 120, saturation || defaultS, l);

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
    const primarySat = document.querySelector("#primary-sat")
    const updateButton = document.querySelector("#set-colors")

    generateHslaColors(50, 50).forEach((e) => {
      const div = document.createElement("div")
      const hex = hslToHex(e.hue, e.saturation, e.lightness)
      div.style.backgroundColor = hex
      div.dataset.value = hex
      div.style.flex = 1
      selector.appendChild(div)
    })

    // previous value set or the first color in the palette
    setTheme(primary.value || selector.firstChild.dataset.value)

    selector.addEventListener("click", ({ target: { dataset: { value }}}) => setTheme(value, Number(primarySat.value)));
    primarySat.addEventListener("input", ({ target: { value }}) => setTheme(primary.value, Number(value)));
    updateButton.addEventListener("click", (e) => {
      e.preventDefault()

      document.querySelector("#organization_primary_color").value = document.querySelector("#preview-primary").value
      document.querySelector("#organization_secondary_color").value = document.querySelector("#preview-secondary").value
    });
  }
})
