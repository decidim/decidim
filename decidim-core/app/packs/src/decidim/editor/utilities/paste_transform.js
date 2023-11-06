const parseMsoListStyles = (doc) => {
  const style = doc.querySelector("style")?.textContent;
  if (!style) {
    return {};
  }

  const listStyles = {};
  [...style.matchAll(/@list\s+(l\d+:level\d+)[\s]+\{([^}]+)\}/g)].forEach((match) => {
    const styleDefs = {};
    match[2].replace(/[\s]+/g, "").split(";").forEach((styleDef) => {
      const [key, val] = styleDef.split(":");
      styleDefs[key] = val;
    });
    listStyles[match[1]] = styleDefs;
  });

  return listStyles;
};

const detectMsoList = (element) => {
  const currentStyle = element.getAttribute("style");
  if (!currentStyle) {
    return { type: null, level: 1 };
  }
  const listStyleMatch = currentStyle.match(/mso-list:(l\d+)\s(level\d+)/);
  if (listStyleMatch) {
    const [, type, level] = listStyleMatch;
    return { type, level: parseInt(level.match(/\d/), 10) };
  }
  return { type: null, level: 1 };
};

const getMsoListStyle = (type, level, styleDefs) => {
  if (type === null) {
    return {};
  }

  const typeStyle = styleDefs[type] || {};
  const levelStyle = styleDefs[`${type}:level${level}`] || {};
  return Object.assign(typeStyle, levelStyle);
};

const converMsoListStyleToHtml = (listStyle) => {
  let tag = "ol",
      type = null;
  switch (listStyle["mso-level-number-format"]) {
  case "bullet":
    tag = "ul";
    break;
  case "alpha-lower":
  case "lower-alpha":
    type = "a";
    break;
  case "alpha-upper":
  case "upper-alpha":
    type = "A";
    break;
  case "roman-lower":
  case "lower-roman":
    type = "i";
    break;
  case "roman-upper":
  case "upper-roman":
    type = "I";
    break;
  default:
    type = "1";
    break;
  }

  return { tag, type };
};

export const removeMsMetaSegments = (html) => {
  return html.replace(/<!\[if\s+[^\]]+\]>((?!<!\[endif\])[\s\S])+<!\[endif\]>/g, "");
}

/**
 * Fixes issues pasting content from desktop version of Word. Replaces the flat
 * lists represented with `<p>` elements with actual list hierarchy based on the
 * data available in the HTML copied from desktop Word.
 *
 * See: https://github.com/ueberdosis/tiptap/issues/3756
 *
 * @param {String} html The original HTML pasted to the editor.
 * @returns {String} The transformed HTML that fixes the list markup to be
 *   correctly represented on an HTML document.
 */
export const transformMsDesktop = (html) => {
  const doc = document.createElement("div");
  doc.innerHTML = removeMsMetaSegments(html);

  const elements = doc.querySelectorAll([
    ".MsoListParagraph",
    ".MsoListParagraphCxSpFirst",
    ".MsoListParagraphCxSpMiddle",
    ".MsoListParagraphCxSpLast"
  ].join(", "));
  if (elements.length < 1) {
    return html;
  }

  const listStyles = parseMsoListStyles(doc);
  doc.querySelector("style")?.remove();

  let currentLevel = 1,
      currentList = null;
  elements.forEach((paragraph) => {
    const { type: msoType, level } = detectMsoList(paragraph);
    const listStyle = getMsoListStyle(msoType, level, listStyles);
    const { tag, type } = converMsoListStyleToHtml(listStyle);

    const li = document.createElement("li");
    const pa = document.createElement("p");
    pa.innerHTML = paragraph.innerHTML;
    li.append(pa);

    if (paragraph.classList.contains("MsoListParagraph") || paragraph.classList.contains("MsoListParagraphCxSpFirst")) {
      currentLevel = 1;
      currentList = document.createElement(tag);
      if (tag === "ol" && type) {
        currentList.setAttribute("type", type);
      }

      currentList.append(li);
      paragraph.replaceWith(currentList);
    } else {
      if (level > currentLevel) {
        currentLevel += 1;

        const subList = document.createElement(tag);
        if (tag === "ol" && type) {
          subList.setAttribute("type", type);
        }
        if (level === currentLevel) {
          subList.append(li);
        } else {
          const subLi = document.createElement("li");
          const subPa = document.createElement("p");
          subLi.append(subPa);
          subList.append(subLi);
        }
        currentList.lastElementChild.append(subList);
        currentList = subList;
      } else {
        while (level < currentLevel) {
          currentLevel -= 1;
          const candidate = currentList.parentNode.closest("ol, ul");
          if (candidate) {
            currentList = candidate;
          } else {
            currentLevel = level;
            break;
          }
        }
        currentList.append(li);
      }

      if (paragraph.classList.contains("MsoListParagraphCxSpLast")) {
        currentLevel = 1;
        currentList = null;
      }

      paragraph.remove();
    }
  });

  return doc.innerHTML;
}

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
        while (level < currentLevel) {
          currentLevel -= 1;
          const candidate = parent.parentNode.closest("ol, ul");
          if (candidate) {
            parent = candidate;
          } else {
            currentLevel = level;
            break;
          }
        }
        documentCurrentLevel = level;
        parent.append(...listElement.querySelectorAll("li"));
        listElement.remove();
      }

      wrapper.remove();
    });
  });

  return doc.innerHTML;
};

const transformers = [transformMsDesktop, transformMsCould];

export default (html) => {
  let final = html;
  transformers.forEach((method) => (final = method(final)));
  return final;
};
