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
    const command = selectCommand;
    if (currentRange) {
      // Fixes an issue that after selecting the item, the written text will be
      // placed after the newly added suggestion.
      currentEditor.chain().focus().setTextSelection(currentRange).command(({ tr }) => {
        tr.replaceSelectionWith(currentEditor.schema.text("  "));

        return true;
      }).setTextSelection({ from: currentRange.from, to: currentRange.from }).run();
    }
    command(convertItem(items[idx]));
  };

  return {
    onStart({ editor, items, command }) {
      currentEditor = editor;
      suggestionItems = items;
      selectCommand = command;
      suggestion = document.createElement("div");
      document.body.append(suggestion);
      suggestion.classList.add("editor-suggestions", "hidden", "hide");

      console.log("START");
    },

    onUpdate({ clientRect, items }) {
      console.log("UPDATE");
      if (!clientRect || !suggestion) {
        return;
      }

      suggestionItems = items;

      const rect = clientRect();
      Object.assign(suggestion.style, {
        position: "absolute",
        top: `${document.documentElement.scrollTop + rect.top + rect.height}px`,
        left: `${rect.left}px`
      });

      suggestion.classList.remove("hidden", "hide");
      suggestion.innerHTML = "";
      items.forEach((rawItem, idx) => {
        const { label, id } = convertItem(rawItem);
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
        suggestionItem.innerText = label;
        suggestion.append(suggestionItem);

        suggestionItem.addEventListener("click", () => selectItem(idx));
      });
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
      console.log("EXIT");
      suggestion.remove();

      suggestion = suggestionItems = selectCommand = currentEditor = currentRange = null;
      selectedIndex = -1;
    }
  }
};

export const createNodeView = (self) => {
  return ({ node }) => {
    const dom = document.createElement("span");
    dom.innerText = self.options.renderLabel({ options: self.options, node });

    const { id, label } = node.attrs;
    dom.dataset.suggestion = node.type.name;
    if (id) {
      dom.dataset.id = id;
    }
    dom.dataset.label = label;

    return { dom };
  };
};
