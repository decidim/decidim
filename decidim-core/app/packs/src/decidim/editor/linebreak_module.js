/* eslint-disable require-jsdoc */

import addEnterBindings from "src/decidim/editor/modified_enter"
import backspaceBindingsRangeAny from "src/decidim/editor/modified_backspace_offset_any"
import backspaceBindings from "src/decidim/editor/modified_backspace_offset1"
import HistoryOverride from "src/decidim/editor/history_override"

// Disable warning messages from overwritting modules
Quill.debug("error");

// It all started with these snippets of code: https://github.com/quilljs/quill/issues/252
const Delta = Quill.import("delta");
const Break = Quill.import("blots/break");
const Embed = Quill.import("blots/embed");
const Scroll = Quill.import("blots/scroll");
const Parchment = Quill.import("parchment");
Quill.register({"modules/history": HistoryOverride}, true);
let icons = Quill.import("ui/icons");
icons.linebreak = "⏎";

class SmartBreak extends Break {
  length() {
    return 1;
  }

  value() {
    return "\n";
  }

  insertInto(parent, ref) {
    // Embed.prototype.insertInto.call(this, parent, ref);
    Reflect.apply(Embed.prototype.insertInto, this, [parent, ref]);
  }
}
Quill.register(SmartBreak);

// Override quill/blots/scroll.js
class ScrollOvderride extends Scroll {
  optimize(mutations = [], context = {}) {
    if (this.batch === true) {
      return;
    }

    this.parchmentOptimize(mutations, context);

    if (mutations.length > 0) {
      // quill/core/emitter.js, Emitter.events.SCROLL_OPTIMIZE = "scroll-optimize"
      this.emitter.emit("scroll-optimize", mutations, context);
    }
  }

  // Override parchment/src/blot/scroll.ts
  parchmentOptimize(mutations = [], context = {}) {
    // super.optimize(context);
    Reflect.apply(Parchment.Container.prototype.optimize, this, [context]);

    // We must modify mutations directly, cannot make copy and then modify
    // let records = [].slice.call(this.observer.takeRecords());
    let records = [...this.observer.takeRecords()];
    // Array.push currently seems to be implemented by a non-tail recursive function
    // so we cannot just mutations.push.apply(mutations, this.observer.takeRecords());
    while (records.length > 0) {
      mutations.push(records.pop());
    }
    let mark = (blot, markParent) => {
      if (!blot || blot === this) {
        return;
      }
      if (!blot.domNode.parentNode) {
        return;
      }
      if (blot.domNode.__blot && blot.domNode.__blot.mutations === null) {
        blot.domNode.__blot.mutations = [];
      }
      if (markParent) {
        mark(blot.parent);
      }
    };
    let optimize = (blot) => {
      // Post-order traversal
      if (!blot.domNode.__blot) {
        return;
      }

      if (blot instanceof Parchment.Container) {
        blot.children.forEach(optimize);
      }
      blot.optimize(context);
    };
    let remaining = mutations;
    for (let ind = 0; remaining.length > 0; ind += 1) {
      // MAX_OPTIMIZE_ITERATIONS = 100
      if (ind >= 100) {
        throw new Error("[Parchment] Maximum optimize iterations reached");
      }
      remaining.forEach((mutation) => {
        let blot = Parchment.find(mutation.target, true);
        if (!blot) {
          return;
        }
        if (blot.domNode === mutation.target) {
          if (mutation.type === "childList") {
            mark(Parchment.find(mutation.previousSibling, false));

            mutation.addedNodes.forEach((node) => {
              let child = Parchment.find(node, false);
              mark(child, false);
              if (child instanceof Parchment.Container) {
                child.children.forEach(function(grandChild) {
                  mark(grandChild, false);
                });
              }
            });
          } else if (mutation.type === "attributes") {
            mark(blot.prev);
          }
        }
        mark(blot);
      });
      this.children.forEach(optimize);
      remaining = [...this.observer.takeRecords()];
      records = remaining.slice();
      while (records.length > 0) {
        mutations.push(records.pop());
      }
    }
  }
};
Quill.register("blots/scroll", ScrollOvderride, true);
Parchment.register(ScrollOvderride);

export default function lineBreakButtonHandler(quill) {
  let range = quill.selection.getRange()[0];
  let currentLeaf = quill.getLeaf(range.index)[0];
  let nextLeaf = quill.getLeaf(range.index + 1)[0];
  const previousChar = quill.getText(range.index - 1, 1);

  // Insert a second break if:
  // At the end of the editor, OR next leaf has a different parent (<p>)
  if (nextLeaf === null || (currentLeaf.parent !== nextLeaf.parent)) {
    quill.insertEmbed(range.index, "break", true, "user");
    quill.insertEmbed(range.index, "break", true, "user");
  } else if (previousChar === "\n") {
    const delta = new Delta().retain(range.index).insert("\n");
    quill.updateContents(delta, Quill.sources.USER);
  } else {
    quill.insertEmbed(range.index, "break", true, "user");
  }

  // Now that we've inserted a line break, move the cursor forward
  quill.setSelection(range.index + 1, Quill.sources.SILENT);
}

Quill.register("modules/linebreak", (quill) => {
  quill.getModule("toolbar").addHandler("linebreak", () => {
    lineBreakButtonHandler(quill);
  });

  quill.emitter.on("editor-ready", () => {
    const length = quill.getLength();
    const text = quill.getText(length - 2, 2);

    // Remove extraneous new lines
    if (text === "\n\n") {
      quill.deleteText(quill.getLength() - 2, 2);
    }
  });

  addEnterBindings(quill);
  backspaceBindingsRangeAny(quill);
  backspaceBindings(quill);

  return;
});

