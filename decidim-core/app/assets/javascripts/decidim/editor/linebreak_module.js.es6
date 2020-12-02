// = require decidim/editor/modified_enter
// = require decidim/editor/modified_backspace_utils
// = require decidim/editor/modified_backspace_offset_any
// = require decidim/editor/modified_backspace_offset1

((exports) => {
  const Quill = exports.Quill;
  const Break = Quill.import("blots/break");
  const Embed = Quill.import("blots/embed");
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

    quill.insertEmbed(range.index, "break", true, "user");

    // Insert a second break if:
    // At the end of the editor, OR next leaf has a different parent (<p>)
    if (nextLeaf === null || (currentLeaf.parent !== nextLeaf.parent)) {
      quill.insertEmbed(range.index, "break", true, "user");
    }

    // Now that we've inserted a line break, move the cursor forward
    quill.setSelection(range.index + 1, Quill.sources.SILENT);
  };

  Quill.register("modules/linebreak", (quill) => {
    const { addEnterBindings } = exports.Editor;
    const { backspaceBindingsRangeAny } = exports.Editor;
    const { backspaceBindings } = exports.Editor;

    quill.getModule("toolbar").addHandler("linebreak", () => {
      lineBreakButtonHandler(quill);
    });

    quill.emitter.on("editor-ready", () => {
      const length = quill.getLength()
      const text = quill.getText(length - 2, 2)

      // console.log(quill.getText().replace(/\n/g, "\\n"));

      // Remove extraneous new lines
      if (text === "\n\n") {
        quill.deleteText(quill.getLength() - 2, 2)
      }
    });
    addEnterBindings(quill);
    backspaceBindingsRangeAny(quill);
    backspaceBindings(quill);

    return;
  });

  exports.Editor.lineBreakButtonHandler = lineBreakButtonHandler;
})(window);
