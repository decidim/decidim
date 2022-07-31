import { BlockEmbed } from "quill/blots/block";

const Delta = Quill.import("delta");
const Parchment = Quill.import("parchment");

// Newer version used only for the pasting, not compatible with the version of
// Quill in use.
const traverse = (scroll, node, elementMatchers, textMatchers, nodeMatches) => { // eslint-disable-line max-params
  // Post-order
  if (node.nodeType === node.TEXT_NODE) {
    return textMatchers.reduce((delta, matcher) => {
      return matcher(node, delta, scroll);
    }, new Delta());
  }
  if (node.nodeType === node.ELEMENT_NODE) {
    return Array.from(node.childNodes || []).reduce((delta, childNode) => {
      let childrenDelta = traverse(
        scroll,
        childNode,
        elementMatchers,
        textMatchers,
        nodeMatches,
      );
      if (childNode.nodeType === node.ELEMENT_NODE) {
        childrenDelta = elementMatchers.reduce((reducedDelta, matcher) => {
          return matcher(childNode, reducedDelta, scroll);
        }, childrenDelta);
        childrenDelta = (nodeMatches.get(childNode) || []).reduce(
          (reducedDelta, matcher) => {
            return matcher(childNode, reducedDelta, scroll);
          },
          childrenDelta,
        );
      }
      return delta.concat(childrenDelta);
    }, new Delta());
  }
  return new Delta();
}

const deltaEndsWith = (delta, text) => {
  let endText = "";
  for (let idx = delta.ops.length - 1; idx >= 0 && endText.length < text.length; idx -= 1) {
    const op = delta.ops[idx];
    if (typeof op.insert !== "string") {
      break;
    }
    endText = op.insert + endText;
  }
  return endText.slice(-1 * text.length) === text;
}

const isLine = (node) => {
  if (node.childNodes.length === 0) {
    // Exclude embed blocks
    return false;
  }
  return [
    "address", "article", "blockquote", "canvas", "dd", "div", "dl", "dt",
    "fieldset", "figcaption", "figure", "footer", "form", "h1", "h2", "h3",
    "h4", "h5", "h6", "header", "iframe", "li", "main", "nav", "ol", "output",
    "p", "pre", "section", "table", "td", "tr", "ul", "video"
  ].includes(node.tagName.toLowerCase());
}

const matchNewLineScroll = (nextSibling, delta, scroll) => {
  if (!scroll) {
    return null;
  }

  const match = Parchment.query(nextSibling)
  if (match && match.prototype instanceof BlockEmbed) {
    return delta.insert("\n");
  }
  return null;
}

const matchNewline = (node, delta, scroll) => {
  if (!deltaEndsWith(delta, "\n")) {
    // When scroll is defined, it was initiated from the paste event. Otherwise
    // it is a normal Quill initiated traversal which handles adding the line
    // breaks already.
    if (scroll && node.nodeType === node.ELEMENT_NODE && node.tagName === "BR") {
      return delta.insert({"break": ""});
    }
    if (isLine(node)) {
      return delta.insert("\n");
    }
    if (delta.length() > 0 && node.nextSibling) {
      let { nextSibling } = node;
      while (nextSibling !== null) {
        if (isLine(nextSibling)) {
          return delta.insert("\n");
        }
        const scrollMatch = matchNewLineScroll(nextSibling, delta, scroll);
        if (scrollMatch) {
          return scrollMatch;
        }
        nextSibling = nextSibling.firstChild;
      }
    }
  }
  return delta;
}

const matchBreak = (node, delta) => {
  if (!deltaEndsWith(delta, "\n")) {
    delta.insert({"break": ""});
  }
  return delta;
}

export {
  traverse,
  deltaEndsWith,
  isLine,
  matchNewline,
  matchBreak
}
