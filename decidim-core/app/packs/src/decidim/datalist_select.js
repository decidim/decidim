/**
// Function adds feature to datalist that you can have different id and label.
// Used with datalist_select_helper.rb#datalist_select
 * @param {HTMLElement} target - dataselect wrapper
 * @param {Function} callback - the function to be executed after a successful selection.
 * @returns {Void} - Returns nothing.
 */

export const datalistSelect = (target, callback) => {
  if (!target) {
    return;
  }

  const input = target.querySelector("input[type='hidden'");
  const textInput = target.querySelector("input[type='text']");
  const items = target.querySelector("datalist").children;

  const selectValue = (selected) => {
    for (let idx = 0; idx < items.length; idx += 1) {
      if (items[idx].innerHTML === selected) {
        const id = items[idx].dataset.value;
        input.value = id;
        if (callback) {
          return callback(id);
        }
        return true;
      }
    }
    return false;
  }

  textInput.addEventListener("input", () => {
    const selected = textInput.value;
    selectValue(selected);
  })
}
