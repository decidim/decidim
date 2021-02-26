import './modified_enter'
import './modified_backspace_utils'
import './modified_backspace_offset_any'
import './modified_backspace_offset1'
import './history_override'

// It all started with these snippets of code: https://github.com/quilljs/quill/issues/252
((exports) => {
  const Quill = exports.Quill;
  const Delta = Quill.import("delta");
  const Break = Quill.import("blots/break");
  const Embed = Quill.import("blots/embed");
  const { HistoryOverride } = exports.Decidim.Editor
  Quill.register({"modules/history": HistoryOverride}, true)
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

  const lineBreakButtonHandler = (quill) => {
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
  };

  Quill.register("modules/linebreak", (quill) => {
    const { addEnterBindings } = exports.Decidim.Editor;
    const { backspaceBindingsRangeAny } = exports.Decidim.Editor;
    const { backspaceBindings } = exports.Decidim.Editor;

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

  exports.Decidim.Editor.lineBreakButtonHandler = lineBreakButtonHandler;
})(window);
