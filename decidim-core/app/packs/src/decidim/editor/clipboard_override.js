/* eslint max-lines: ["error", 350] */

import CodeBlock from "quill/formats/code";
import { matchNewline, matchBreak, deltaEndsWith, traverse } from "src/decidim/editor/clipboard_utilities";

const Delta = Quill.import("delta");
const Clipboard = Quill.import("modules/clipboard");

/**
 * Pasting bold text is broken in Quill as described at:
 * https://github.com/quilljs/quill/issues/306
 *
 * The reason is that the `<strong>` nodes are not recognized as bold types.
 * This override fixes the issue by introducing parts of the newer Quill code
 * at GitHub and defining the `<strong>` tags as bold tags.
 */
export default class ClipboardOverride extends Clipboard {
  constructor(quill, options) {
    super(quill, options);
    this.overrideMatcher("b", "b, strong");
    this.overrideMatcher("br", "br", matchBreak);

    // Change the matchNewLine matchers to the newer version
    this.matchers[1][1] = matchNewline;
    this.matchers[3][1] = matchNewline;

    // Remove `matchSpacing` as that is also removed in the newer versions.
    this.matchers.splice(5, 1);
  }

  overrideMatcher(originalSelector, newSelector, newMatcher = null) {
    const idx = this.matchers.findIndex((item) => item[0] === originalSelector);
    if (idx >= 0) {
      this.matchers[idx][0] = newSelector;
      if (newMatcher) {
        this.matchers[idx][1] = newMatcher;
      }
    }
  }

  onPaste(ev) {
    if (ev.defaultPrevented || !this.quill.isEnabled()) {
      return;
    }
    ev.preventDefault();
    const range = this.quill.getSelection(true);
    if (range === null) {
      return;
    }
    const html = ev.clipboardData.getData("text/html");
    const text = ev.clipboardData.getData("text/plain");
    const files = Array.from(ev.clipboardData.files || []);
    if (!html && files.length > 0) {
      this.quill.uploader.upload(range, files);
      return;
    }
    if (html && files.length > 0) {
      const doc = new DOMParser().parseFromString(html, "text/html");
      if (
        doc.body.childElementCount === 1 &&
        doc.body.firstElementChild.tagName === "IMG"
      ) {
        this.quill.uploader.upload(range, files);
        return;
      }
    }
    this.onPasteRange(range, { html, text });
  }

  onPasteRange(range, { text, html }) {
    const formats = this.quill.getFormat(range.index);
    const pastedDelta = this.convertPaste({ text, html }, formats);
    // debug.log('onPaste", pastedDelta, { text, html });
    const delta = new Delta().retain(range.index).delete(range.length).concat(pastedDelta);
    this.quill.updateContents(delta, Quill.sources.USER);
    // range.length contributes to delta.length()
    this.quill.setSelection(
      delta.length() - range.length,
      Quill.sources.SILENT,
    );
    this.quill.scrollIntoView();
  }

  convertPaste({ html, text }, formats = {}) {
    if (formats[CodeBlock.blotName]) {
      return new Delta().insert(text, {
        [CodeBlock.blotName]: formats[CodeBlock.blotName]
      });
    }
    if (!html) {
      return new Delta().insert(text || "");
    }
    const delta = this.convertPasteHTML(html);
    // Remove trailing newline
    if (
      deltaEndsWith(delta, "\n") &&
      (delta.ops[delta.ops.length - 1].attributes === null || formats.table)
    ) {
      return delta.compose(new Delta().retain(delta.length() - 1).delete(1));
    }
    return delta;
  }

  convertPasteHTML(html) {
    const doc = new DOMParser().parseFromString(html, "text/html");
    const container = doc.body;
    const nodeMatches = new WeakMap();
    const [elementMatchers, textMatchers] = this.prepareMatching(
      container,
      nodeMatches
    );
    return traverse(
      this.quill.scroll,
      container,
      elementMatchers,
      textMatchers,
      nodeMatches
    );
  }
}

// Disable warning messages from overwritting modules
Quill.debug("error");
Quill.register({"modules/clipboard": ClipboardOverride}, true);
