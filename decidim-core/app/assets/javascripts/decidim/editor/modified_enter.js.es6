
((exports) => {
  const Quill = exports.Quill;
  const Parchment = Quill.import("parchment")
  const Delta = Quill.import("delta");

  const getLineFormats = (context) => {
    return Object.keys(context.format).reduce(
      (formats, format) => {
        // See Parchment registry.ts => (1 << 3) | ((1 << 2) - 1) = 8 | 3 = 11
        const blockScope = 11;
        if (
          Parchment.query(format, blockScope) &&
          !Array.isArray(context.format[format])
        ) {
          formats[format] = context.format[format];
        }
        return formats;
      },
      {},
    );
  }

  const continueFormats = (quill, context, lineFormats) => {
    Object.keys(context.format).forEach((name) => {
      if (typeof lineFormats[name] !== "undefined" && lineFormats[name] !== null) {
        return;
      }
      if (Array.isArray(context.format[name])) {
        return;
      }
      if (name === "link") {
        return;
      }
      quill.format(name, context.format[name], Quill.sources.USER);
    });
  }

  const lineBreakHandler = (quill, range, context) => {
    const currentLeaf = quill.getLeaf(range.index)[0];
    const nextLeaf = quill.getLeaf(range.index + 1)[0];
    const previousChar = quill.getText(range.index - 1, 1);
    const formats = quill.getFormat(range.index);

    if ((currentLeaf && currentLeaf.next && currentLeaf.next.domNode &&
      currentLeaf.next.domNode.tagName && currentLeaf.next.domNode.tagName === "A") ||
      (nextLeaf && nextLeaf.parent && nextLeaf.parent.domNode && nextLeaf.parent.domNode.tagName &&
        nextLeaf.parent.domNode.tagName === "A")) {
      quill.insertEmbed(range.index, "break", true, "user");
      quill.removeFormat(range.index, 1, Quill.sources.SILENT)
    } else {
      quill.insertEmbed(range.index, "break", true, "user");
    }

    if (nextLeaf === null) {
      quill.insertEmbed(range.index, "break", true, "user");
    } else if (context.offset === 1 && previousChar === "\n") {
      const delta = new Delta().retain(range.index).insert("\n");
      quill.updateContents(delta, Quill.sources.USER);
    }

    Object.keys(formats).forEach((format) => {
      quill.format(format, context.format[format], Quill.sources.USER);
    });
    quill.setSelection(range.index + 1, Quill.sources.SILENT);

    const lineFormats = getLineFormats(context);
    continueFormats(quill, context, lineFormats);
  };

  const addEnterBindings = (quill) => {
    quill.keyboard.addBinding({
      key: 13,
      shiftKey: true
    }, (range, context) => {
      lineBreakHandler(quill, range, context);
    });

    // HAX: make our SHIFT+ENTER binding the second (first is added below) in order to override Quill defaults
    quill.keyboard.bindings[13].unshift(quill.keyboard.bindings[13].pop());

    quill.keyboard.addBinding({ key: 13, shiftKey: false }, (range, context) => {
      const lineFormats = getLineFormats(context);
      const previousChar = quill.getText(range.index - 1, 1);
      const nextChar = quill.getText(range.index, 1);
      const delta = new Delta().retain(range.index).insert("\n", lineFormats);
      // const length = context.prefix.length;
      if (previousChar === "" || previousChar === "\n") {
        if (lineFormats.list && nextChar === "\n") {
          if (quill.getLength() - range.index > 2) {
            const endFormatDelta = new Delta().retain(range.index - 1).delete(1);
            quill.updateContents(endFormatDelta, Quill.sources.USER);
          } else {
            // Delete empty list item and end the list
            const endFormatDelta = new Delta().retain(range.index - 1).delete(1).retain(range.index).insert("\n");
            quill.updateContents(endFormatDelta, Quill.sources.USER);
            quill.setSelection(range.index + 1, Quill.sources.SILENT);
          }
        } else {
          quill.updateContents(delta, Quill.sources.USER);
          if (context.offset === 1 && previousChar === "\n") {
            quill.setSelection(range.index + 1, Quill.sources.SILENT);
          } else {
            quill.setSelection(range.index + 2, Quill.sources.SILENT);
          }
        }
      } else {
        quill.updateContents(delta, Quill.sources.USER);
        quill.setSelection(range.index + 1, Quill.sources.SILENT);
      }
      quill.focus();

      continueFormats(quill, context, lineFormats);
    });

    // Replace the default enter handling because we have modified the break element
    quill.keyboard.bindings[13].unshift(quill.keyboard.bindings[13].pop());
    return;
  }

  exports.Decidim.Editor = exports.Decidim.Editor || {};
  exports.Decidim.Editor.addEnterBindings = addEnterBindings;
})(window)
