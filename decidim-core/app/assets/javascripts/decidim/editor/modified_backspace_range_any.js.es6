((exports) => {
  const Quill = exports.Quill;
  // const Delta = Quill.import("delta");
  const { attributeDiff } = exports.Editor

  const backspaceBindingsRangeAny = (quill) => {
    quill.keyboard.addBinding({ key: 8, altKey: null, ctrlKey: null, metaKey: null, shiftKey: null, collapsed: true }, (range, context) => {
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

          // console.log("curFormats", curFormats)
          // console.log("prevFormats", prevFormats)
          // console.log("context.offset", context.offset)
          // console.log("prevline", quill.getLine(range.index - 1))
          const previousLineLength = quill.getLine(range.index - 1)[1];
          const beforePreviousChar = quill.getText(range.index - 2, 1);
          if (prevFormats && prevFormats.list && previousLineLength && previousLineLength === 1 && beforePreviousChar === "\n") {
            quill.setSelection(range.index - 2, Quill.sources.SILENT);
          }
        }
      }
      let length = /[\uD800-\uDBFF][\uDC00-\uDFFF]$/.test(context.prefix) ? 2 : 1;
      // console.log("length", length)
      quill.deleteText(range.index - length, length, Quill.sources.USER);

      // console.log("formats", formats)
      if (Object.keys(formats).length > 0) {
        quill.formatLine(range.index - length, length, formats, Quill.sources.USER);
      }
      quill.focus();
    })
    quill.keyboard.bindings[8].splice(1, 0, quill.keyboard.bindings[8].pop());
  }

  exports.Editor.backspaceBindingsRangeAny = backspaceBindingsRangeAny
})(window)
