// = require decidim/editor/modified_enter
// = require decidim/editor/modified_backspace_utils
// = require decidim/editor/modified_backspace_range_any
// = require decidim/editor/modified_backspace_range1

((exports) => {
  const Quill = exports.Quill;
  let icons = Quill.import("ui/icons");
  icons.linebreak = "⏎";

  Quill.register("modules/linebreak", (quill) => {
    const { lineBreakHandler } = exports.Editor;
    const { addEnterBindings } = exports.Editor;
    const { backspaceBindingsRangeAny } = exports.Editor;
    const { backspaceBindings } = exports.Editor;

    quill.getModule("toolbar").addHandler("linebreak", () => {
      lineBreakHandler(quill);
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

})(window);
