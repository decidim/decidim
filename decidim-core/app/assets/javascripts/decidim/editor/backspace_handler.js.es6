((exports) => {
  const Quill = exports.Quill;
  const Delta = Quill.import("delta");

  const attributeDiff = (alpha, beta) => {
    if (typeof a !== "object") {
      alpha = {};
    }
    if (typeof b !== "object") {
      beta = {};
    }
    const attributes = Object.keys(alpha).concat(Object.keys(beta)).reduce((attrs, key) => {
      // if (!isEqual(a[key], b[key])) {
      if (alpha[key] !== beta[key]) {
        attrs[key] = beta[key] === undefined ? null : beta[key];
      }
      return attrs;
    }, {});
    // console.log("attributes", attributes)

    return Object.keys(attributes).length > 0 ? attributes : undefined;
  }

  const backspaceBindings = (quill) => {
    quill.keyboard.addBinding({ key: 8, offset: 1 }, (range, context) => {
      const previousChar = quill.getText(range.index - 1, 1);
      const nextChar = quill.getText(range.index, 1)
      // console.log("range", range)
      // console.log("context", context)
      // console.log(`previousChar_${previousChar}_previousChar`)
      const length = /[\uD800-\uDBFF][\uDC00-\uDFFF]$/.test(context.prefix) ? 2 : 1;
      if (range.index === 0 || quill.getLength() <= 1) {
        return;
      }
      let formats = {};
      const [line] = quill.getLine(range.index);
      let delta = new Delta().retain(range.index - length).delete(length);
      if (context.offset === 1 && previousChar === "\n") {
        const [prev] = quill.getLine(range.index - 2);
        if (prev && prev.statics.blotName === "list-item") {
          if (prev != null && prev.length() > 1) {
            let curFormats = line.formats();
            let prevFormats = quill.getFormat(range.index-1, 1);
            formats = attributeDiff(curFormats, prevFormats) || {};
          }
          console.log(`prevChar_${previousChar}_prevChar`)
          console.log(`ÄLÄ DELETEE LISTAA_${quill.getText(range.index - 2, 1)}_TOKAVIKA`);
          console.log("range.index", range.index)
          delta = new Delta().retain(range.index - 2).delete(2).insert("\n", { list: "bullet" });
          if (nextChar === "\n") {
            quill.setSelection(range.index - 1, Quill.sources.SILENT);
          }
        } else {
          console.log("ELSE")
          delta = new Delta().retain(range.index + line.length() - 2).delete(1)
          quill.deleteText(range.index - 2, 2)
        }

      } else {
        const [prev] = quill.getLine(range.index - 1);
        if (prev) {
          const isPrevLineEmpty =
            prev.statics.blotName === "block" && prev.length() <= 1;
          if (!isPrevLineEmpty) {
            const curFormats = line.formats();
            const prevFormats = quill.getFormat(range.index - 1, 1);
            // console.log("curFormats", curFormats)
            // console.log("prevFormats", prevFormats)
            formats = attributeDiff(curFormats, prevFormats) || {};
            // console.log("foramts", formats)
            if (Object.keys(formats).length > 0) {
              // line.length() - 1 targets \n in line, another -1 for newline being deleted
              const formatDelta = new Delta().retain(range.index + line.length() - 2).retain(1, formats);
              delta = delta.compose(formatDelta);
            }
          }
        }
      }
      quill.updateContents(delta, Quill.sources.USER);
      quill.focus();
      console.log("ops after", quill.getContents().ops)
    });
    // const backspaceHandlerIndex = quill.keyboard.bindings[8].findIndex((bindDef) => {
    //   return bindDef.collapsed === true && typeof bindDef.format === "undefined" && bindDef.shiftKey === null;
    // });
    // quill.keyboard.bindings[8].splice(backspaceHandlerIndex, 1);
    // const lastBackspaceBinding = quill.keyboard.bindings[8].pop();
    quill.keyboard.bindings[8].unshift(quill.keyboard.bindings[8].pop());
    // console.log(quill.keyboard.bindings[8]);
  }

  exports.Decidim.backspaceBindings = backspaceBindings;
})(window)
