// = require decidim/editor/linebreak_handler
// = require decidim/editor/backspace_handler

((exports) => {
  const Quill = exports.Quill;
  let icons = Quill.import("ui/icons");
  icons.linebreak = "⏎";

  Quill.register("modules/linebreak", (quill) => {
    const { lineBreakHandler } = exports.Decidim;
    const { addEnterBindings } = exports.Decidim;
    const { backspaceBindings } = exports.Decidim;

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
    backspaceBindings(quill);

    return;
  });

})(window);
