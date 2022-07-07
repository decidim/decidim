export const checkTitles = (parentElement, saveButton) => {
  let everyItemHasTitle = true;

  Array.from(parentElement.children).forEach((item) => {
    const title = item.querySelector("input[type='text']").value;
    const noTitleErrorSpan = item.querySelector(".no-title-error");
    if (!title || title.length === 0) {
      everyItemHasTitle = false;
      saveButton.disabled = true;
      noTitleErrorSpan.classList.add("is-visible");
      item.appendChild(noTitleErrorSpan);
    } else {
      noTitleErrorSpan.classList.remove("is-visible");
    }
  });

  if (everyItemHasTitle) {
    saveButton.disabled = false;
  }
}

export const truncateFilename = (filename, maxLength = 31) => {
  if (filename.length <= maxLength) {
    return filename;
  }

  const charactersFromBegin = Math.floor(maxLength / 2) - 3;
  const charactersFromEnd = maxLength - charactersFromBegin - 3;
  return `${filename.slice(0, charactersFromBegin)}...${filename.slice(-charactersFromEnd)}`;
}

export const createHiddenInput = (elClasses, elName, elValue) => {
  const el = document.createElement("input");
  el.type = "hidden";
  if (elClasses) {
    if (typeof (elClasses) === "string") {
      el.className = elClasses;
    } else {
      el.className = elClasses.join(" ")
    }
  }
  if (elName) {
    el.name = elName;
  }
  if (elValue) {
    el.value = elValue;
  }
  return el;
}
