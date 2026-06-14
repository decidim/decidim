const STATE_INPUT_SELECTOR = 'input[type="checkbox"][name="filter[with_any_state][]"]';
const FALLBACK_ATTR = "data-state-filter-fallback";

const readFallbackValues = () => {
  const host = document.querySelector(`[${FALLBACK_ATTR}]`);
  if (!host) return [];
  return host.getAttribute(FALLBACK_ATTR).split(",").map((v) => v.trim()).filter(Boolean);
};

const stateInputs = () => Array.from(document.querySelectorAll(STATE_INPUT_SELECTOR));

const ensureFallback = () => {
  const inputs = stateInputs();
  if (!inputs.length) return;

  const checkedWithValue = inputs.filter((el) => el.checked && el.value !== "");
  if (checkedWithValue.length > 0) return;

  const fallbackValues = readFallbackValues();
  if (!fallbackValues.length) return;

  const toggledLeaves = [];
  fallbackValues.forEach((value) => {
    const leaf = inputs.find((el) => el.value === value);
    if (leaf && !leaf.checked) {
      leaf.checked = true;
      toggledLeaves.push(leaf);
    }
  });

  toggledLeaves.forEach((leaf) => {
    leaf.dispatchEvent(new Event("change", { bubbles: true }));
  });
};

document.addEventListener("change", (event) => {
  const target = event.target;
  if (!(target instanceof HTMLInputElement)) return;
  if (target.name !== "filter[with_any_state][]") return;
  if (target.value === "") return;

  ensureFallback();
});
