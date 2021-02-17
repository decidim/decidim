((exports) => {
  const Quill = exports.Quill;
  const Delta = Quill.import("delta");
  const { attributeDiff } = exports.Decidim.Editor;

  const previousChar = (quill, range) => {
    return quill.getText(range.index - 1, 1);
  }

  const beforePreviousChar = (quill, range) => {
    return quill.getText(range.index - 2, 1);
  }

  const nextChar = (quill, range) => {
    return quill.getText(range.index, 1);
  }

  const handleListSelection = (quill, range) => {
    const lastCharacterOfPreviousLine = quill.getText(range.index - 3, 1);
    if (nextChar(quill, range) === "\n" || lastCharacterOfPreviousLine !== "\n") {
      quill.setSelection(range.index - 1, Quill.sources.SILENT);
    } else {
      quill.setSelection(range.index - 3, Quill.sources.SILENT);
    }
  }

  const moveSelectionToPreviousLine = (quill, range) => {
    const lastCharacterOfPreviousLine = quill.getText(range.index - 3, 1);
    if (nextChar(quill, range) === "\n" || lastCharacterOfPreviousLine !== "\n") {
      quill.setSelection(range.index - 1, Quill.sources.SILENT);
    } else {
      quill.setSelection(range.index - 3, Quill.sources.SILENT);
    }
  }

  const backspaceBindings = (quill) => {
    quill.keyboard.addBinding({ key: 8, offset: 1, collapsed: true }, (range, context) => {
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
      if (context.offset === 1 && previousChar(quill, range) === "\n") {
        const [prev] = quill.getLine(range.index - 2);
        if (prev && prev.statics.blotName === "list-item") {
          formats = handleListSelection(quill, range);
          if (prev !== null && prev.length() > 1) {
            let curFormats = line.formats();
            let prevFormats = quill.getFormat(range.index - 2, 1);
            formats = attributeDiff(curFormats, prevFormats) || {};
            length += 1;
          }
          delta = new Delta().retain(range.index - 2).delete(2);
          moveSelectionToPreviousLine(quill, range);
        } else {
          delta = new Delta().retain(range.index - 1).delete(1);
          if (range.index < 2) {
            delta = new Delta().delete(1).retain(range.index + line.length() - 1);
          } else if (previousChar(quill, range) === "\n" && beforePreviousChar(quill, range) === "\n") {
            delta = new Delta().retain(range.index - 2).delete(2);
          }
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

  exports.Decidim.Editor.backspaceBindings = backspaceBindings;
})(window)
