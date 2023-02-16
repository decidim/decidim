/**
 * Fixes issues pasting content from Office 365. Modifies the list structure
 * to represent the correct sub-list hierarchy based on the data available in
 * the HTML copied from Office 365. Based on this, Tiptap is able to correctly
 * create the hierarchy structure for the lists.
 *
 * See: https://github.com/ueberdosis/tiptap/issues/3751
 *
 * @param {String} html The original HTML pasted to the editor.
 * @returns {String} The transformed HTML that fixes the list hierarchy to be
 *   correctly represented on an HTML document.
 */
export const transformMsCould = (html) => {
  const doc = document.createElement("div");
  doc.innerHTML = html;

  // Fetch all the MS lists from the pasted content
  const lists = {};
  doc.querySelectorAll(".ListContainerWrapper").forEach((wrapper) => {
    const li = wrapper.querySelector("li[data-listid]");
    lists[li.dataset.listid] ??= [];
    lists[li.dataset.listid].push({ wrapper, level: parseInt(li.dataset.ariaLevel, 10) });
  });
  if (Object.keys(lists).length < 1) {
    return html;
  }

  // Move the list elements to the correct hierarchical positions
  Object.values(lists).forEach((list) => {
    const { wrapper: parentWrapper } = list.shift();

    let parent = parentWrapper.querySelector("ol, ul");
    parentWrapper.replaceWith(parent);

    let currentLevel = 1;
    let documentCurrentLevel = 1;
    list.forEach(({ wrapper, level }) => {
      const listElement = wrapper.querySelector("ol, ul");

      if (level > documentCurrentLevel) {
        let target = null;
        while (level > documentCurrentLevel) {
          documentCurrentLevel += 1;
          if (parent.lastElementChild) {
            currentLevel += 1;
            target = parent.lastElementChild;
          }
        }

        target.append(listElement);
        parent = listElement;
      } else {
        if (level < currentLevel) {
          while (level < documentCurrentLevel) {
            documentCurrentLevel -= 1;
            const candidate = parent.parentNode.closest("ol, ul");
            if (candidate) {
              currentLevel -= 1;
              parent = candidate;
            }
          }
        }
        parent.append(...listElement.querySelectorAll("li"));
        listElement.remove();
      }

      wrapper.remove();
    });
  });

  return doc.innerHTML;
};

export default (html) => {
  return transformMsCould(html);
};
