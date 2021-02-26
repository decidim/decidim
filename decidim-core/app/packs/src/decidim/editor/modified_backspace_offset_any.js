((exports) => {
  const Quill = exports.Quill;
  const { attributeDiff } = exports.Decidim.Editor

  const backspaceBindingsRangeAny = (quill) => {
    quill.keyboard.addBinding({ key: 8, altKey: null, ctrlKey: null, metaKey: null, shiftKey: null, collapsed: true }, (range, context) => {
      let length = 1;
      if (range.index === 0 || quill.getLength() <= 1) {
        return;
      }
      let [line] = quill.getLine(range.index);
      let formats = {};
      if (context.offset === 0) {
        let [prev] = quill.getLine(range.index - 1);
        if (prev !== null && prev.length() > 1) {
          let curFormats = line.formats();
          let prevFormats = quill.getFormat(range.index - 1, 1);
          formats = attributeDiff(curFormats, prevFormats) || {};
          const previousLineLength = quill.getLine(range.index - 1)[1];
          const previousChar = quill.getText(range.index - 1, 1)
          const beforePreviousChar = quill.getText(range.index - 2, 1);
          if (previousLineLength && previousLineLength === 1 && beforePreviousChar === "\n") {
            if (prevFormats && prevFormats.list) {
              quill.setSelection(range.index - 2, Quill.sources.SILENT);
            } else if (previousChar === "\n" && beforePreviousChar === "\n") {
              length += 1;
            }
          }
        }
      }

      if (/[\uD800-\uDBFF][\uDC00-\uDFFF]$/.test(context.prefix)) {
        length += 1;
      }
      quill.deleteText(range.index - length, length, Quill.sources.USER);

      if (Object.keys(formats).length > 0) {
        quill.formatLine(range.index - length, length, formats, Quill.sources.USER);
      }
      quill.focus();
    })

    // Put this backspace binding to second (after backspce_offset1 it's going to be third)
    quill.keyboard.bindings[8].splice(1, 0, quill.keyboard.bindings[8].pop());
  }

  exports.Decidim.Editor.backspaceBindingsRangeAny = backspaceBindingsRangeAny;
})(window)
