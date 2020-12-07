((exports) => {
  const Quill = exports.Quill;
  const Delta = Quill.import("delta");
  const backspaceBindings = (quill) => {
    const { attributeDiff } = exports.Editor;
    quill.keyboard.addBinding({ key: 8, offset: 1, collapsed: true }, (range, context) => {
      const previousChar = quill.getText(range.index - 1, 1);
      const nextChar = quill.getText(range.index, 1);
      let length = 1
      if (/[\uD800-\uDBFF][\uDC00-\uDFFF]$/.test(context.prefix)) {
        length = 2;
      }

      if (range.index === 0 || quill.getLength() <= 1) {
        return;
      }
      let formats = {};
      const [line] = quill.getLine(range.index);
      let delta = new Delta().retain(range.index - length).delete(length);
      if (context.offset === 1 && previousChar === "\n") {
        const [prev] = quill.getLine(range.index - 2);
        if (prev && prev.statics.blotName === "list-item") {
          if (prev !== null && prev.length() > 1) {
            let curFormats = line.formats();
            let prevFormats = quill.getFormat(range.index - 2, 1);
            formats = attributeDiff(curFormats, prevFormats) || {};
            length += 1;
          }
          delta = new Delta().retain(range.index - 2).delete(2);
          if (nextChar === "\n") {
            quill.setSelection(range.index - 1, Quill.sources.SILENT);
          }
        } else {
          delta = new Delta().retain(range.index + line.length() - 2).delete(1);
          quill.deleteText(range.index - 2, 2);
        }
      } else {
        const [prev] = quill.getLine(range.index - 1);
        if (prev) {
          const isPrevLineEmpty =
            prev.statics.blotName === "block" && prev.length() <= 1;
          if (!isPrevLineEmpty) {
            const curFormats = line.formats();
            const prevFormats = quill.getFormat(range.index - 1, 1);
            formats = attributeDiff(curFormats, prevFormats) || {};
            if (Object.keys(formats).length > 0) {
              // line.length() - 1 targets \n in line, another -1 for newline being deleted
              const formatDelta = new Delta().retain(range.index + line.length() - 2).retain(1, formats);
              delta = delta.compose(formatDelta);
            }
          }
        }
      }
      quill.updateContents(delta, Quill.sources.USER);
      if (Object.keys(formats).length > 0) {
        quill.formatLine(range.index - length, length, formats, Quill.sources.USER);
      }
      quill.focus();
    });

    // Put this backspace binding to second
    quill.keyboard.bindings[8].splice(1, 0, quill.keyboard.bindings[8].pop());
  }

  exports.Editor.backspaceBindings = backspaceBindings;
})(window)
