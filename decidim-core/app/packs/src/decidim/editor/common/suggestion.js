/* global jest */

export const createSuggestionRenderer = (node, { itemConverter } = {}) => () => {
  let suggestion = null;
  let suggestionItems = null;
  let selectCommand = null;
  let selectedIndex = -1;
  let currentEditor = null;
  let currentRange = null;

  const convertItem = (item) => {
    let finalItem = item;
    if (itemConverter) {
      finalItem = itemConverter(item);
    }

    if (finalItem instanceof Object) {
      return finalItem;
    }
    return { label: finalItem };
  }

  const updateSelectedItem = (direction) => {
    let count = 0;
    suggestion.querySelectorAll(".editor-suggestions-item").forEach((item, idx) => {
      if (item.dataset.selected === "true") {
        selectedIndex = idx;
      }
      item.removeAttribute("data-selected");
      count += 1;
    });
    if (direction === "up") {
      selectedIndex -= 1;
    } else {
      selectedIndex += 1;
    }
    if (selectedIndex < 0) {
      selectedIndex = 0;
    } else if (selectedIndex === count) {
      selectedIndex -= 1;
    }

    if (selectedIndex > -1) {
      const item = suggestion.querySelector(`.editor-suggestions-item[data-index="${selectedIndex}"]`)
      if (item) {
        item.dataset.selected = "true";
      }
    }
  };

  const selectItem = (idx) => {
    const items = suggestionItems;

    if (items[idx].help) {
      return;
    }

    const command = selectCommand;
    if (currentRange && !window.isTestEnvironment && typeof jest === "undefined") {
      // Fixes an issue that after selecting the item, the written text will be
      // placed after the newly added suggestion.
      //
      // NOTE: With JSDom/Jest this does not work even if we add a delay after
      // changing the text in the selection. This is because the range remains
      // the same for the `command` below which is why the underlying code is
      // trying to do an insertion at a position that is out of range after we
      // have already deleted the content.
      currentEditor.chain().focus().setTextSelection(currentRange).command(({ tr, dispatch }) => {
        if (dispatch) {
          tr.replaceSelectionWith(currentEditor.schema.text("  "));
        }

        return true;
      }).setTextSelection({ from: currentRange.from, to: currentRange.from }).run();
    }
    command(convertItem(items[idx]));
  };

  const showSuggestions = ({ items, clientRect }) => {
    const rect = clientRect();
    Object.assign(suggestion.style, {
      position: "absolute",
      top: `${document.documentElement.scrollTop + rect.top + rect.height}px`,
      left: `${rect.left}px`
    });

    suggestion.classList.remove("hidden", "hide");
    suggestion.innerHTML = "";
    items.forEach((rawItem, idx) => {
      const { label, id, help } = convertItem(rawItem);
      const suggestionItem = document.createElement("button");
      suggestionItem.type = "button";
      suggestionItem.classList.add("editor-suggestions-item");
      if (id) {
        suggestionItem.dataset.id = id;
      }
      suggestionItem.dataset.index = idx;
      suggestionItem.dataset.value = label;
      if (idx === 0) {
        selectedIndex = idx;
        suggestionItem.dataset.selected = "true";
      }
      if (help) {
        suggestionItem.disabled = true;
      }
      suggestionItem.textContent = label;
      suggestion.append(suggestionItem);

      suggestionItem.addEventListener("click", () => selectItem(idx));
    });
  }

  return {
    onStart({ editor, items, clientRect, command }) {
      currentEditor = editor;
      suggestionItems = items;
      selectCommand = command;
      suggestion = document.createElement("div");
      document.body.append(suggestion);
      suggestion.classList.add("editor-suggestions", "hidden", "hide");

      if (items.length > 0) {
        showSuggestions({ clientRect, items });
      }
    },

    onUpdate({ clientRect, items }) {
      if (!clientRect || !suggestion) {
        return;
      }

      suggestionItems = items;

      if (items.length > 0) {
        showSuggestions({ clientRect, items });
      } else {
        suggestion.classList.add("editor-suggestions", "hidden", "hide");
      }
    },

    onKeyDown({ event, range }) {
      currentRange = range;

      if (event.key === "Escape") {
        suggestion.classList.add("hidden", "hide");
        return true;
      } else if (event.key === "ArrowUp") {
        updateSelectedItem("up");
        return true;
      } else if (event.key === "ArrowDown") {
        updateSelectedItem("down");
        return true;
      } else if (event.key === "Enter") {
        if (selectedIndex > -1) {
          selectItem(selectedIndex);
        }
        selectedIndex = -1;
        return true;
      }

      return false;
    },

    onExit() {
      suggestion.remove();

      suggestion = suggestionItems = selectCommand = currentEditor = currentRange = null;
      selectedIndex = -1;
    }
  }
};

export const createNodeView = (self) => {
  return ({ node }) => {
    const dom = document.createElement("span");
    dom.textContent = self.options.renderLabel({ options: self.options, node });

    const { id, label } = node.attrs;
    dom.dataset.suggestion = node.type.name;
    if (id) {
      dom.dataset.id = id;
    }
    dom.dataset.label = label;

    return { dom };
  };
};
