((exports) => {
  const Quill = exports.Quill;
  const Parchment = Quill.import("parchment")
  const Delta = Quill.import("delta");
  const { AttributeMap } = Quill.import("delta");
  const Break = Quill.import("blots/break");
  const Embed = Quill.import("blots/embed");
  let icons = Quill.import("ui/icons");
  icons.linebreak = "⏎";

  const lineBreakHandler = (quill) => {
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
  Quill.register("modules/linebreak", (quill) => {
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

    quill.clipboard.addMatcher("BR", () => {
      let newDelta = new Delta();
      newDelta.insert({"break": ""});
      return newDelta;
    });

    quill.keyboard.addBinding({
      key: 13,
      shiftKey: true
    }, () => {
      lineBreakHandler(quill);
    });

    // HAX: make our binding the first one in order to override Quill defaults
    quill.keyboard.bindings[13].unshift(quill.keyboard.bindings[13].pop());

    // const backspaceHandlerIndex = quill.keyboard.bindings[8].findIndex((bindDef) => {
    //   return bindDef.collapsed === true && typeof bindDef.format === "undefined" && bindDef.shiftKey === null;
    // });
    // quill.keyboard.bindings[8].splice(backspaceHandlerIndex, 1);
    // const lastBackspaceBinding = quill.keyboard.bindings[8].pop();
    quill.keyboard.addBinding({ key: 8, offset: 0 }, (range, context) => {
      // console.log("MEIÄN HANDLERI")
      // console.log("range", range);
      // console.log("context", context)
      const length = /[\uD800-\uDBFF][\uDC00-\uDFFF]$/.test(context.prefix) ? 2 : 1;
      if (range.index === 0 || quill.getLength() <= 1) {
        return;
      }
      let formats = {};
      const [line] = quill.getLine(range.index);
      let delta = new Delta().retain(range.index - length).delete(length);
      if (context.offset === 0) {
        // Always deleting newline here, length always 1
        const [prev] = quill.getLine(range.index - 1);
        if (prev) {
          const isPrevLineEmpty =
            prev.statics.blotName === 'block' && prev.length() <= 1;
          if (!isPrevLineEmpty) {
            const curFormats = line.formats();
            const prevFormats = quill.getFormat(range.index - 1, 1);
            formats = AttributeMap.diff(curFormats, prevFormats) || {};
            if (Object.keys(formats).length > 0) {
              // line.length() - 1 targets \n in line, another -1 for newline being deleted
              const formatDelta = new Delta()
                .retain(range.index + line.length() - 2)
                .retain(1, formats);
              delta = delta.compose(formatDelta);
            }
          }
        }
      }
      quill.updateContents(delta, Quill.sources.USER);
      quill.focus();
    });

    quill.keyboard.bindings[8].unshift(quill.keyboard.bindings[8].pop());


    // Replace the default enter handling because we have modified the break element
    // Normally this is the second last handler
    const enterHandlerIndex = quill.keyboard.bindings[13].findIndex((bindDef) => {
      return typeof bindDef.collapsed === "undefined" && typeof bindDef.format === "undefined" && bindDef.shiftKey === null;
    });
    quill.keyboard.bindings[13].splice(enterHandlerIndex, 1);
    const lastBinding = quill.keyboard.bindings[13].pop();
    quill.keyboard.addBinding({ key: 13 }, (range, context) => {
      const lineFormats = Object.keys(context.format).reduce(
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
      // console.log("lineFormats", lineFormats)
      console.log("ops", quill.getContents().ops)

      const previousChar = quill.getText(range.index - 1, 1);
      const nextChar = quill.getText(range.index, 1);
      const delta = new Delta().retain(range.index).delete(range.length).insert("\n", lineFormats);
      console.log(`nextChar_${nextChar}_nextchar`)
      if (previousChar === "" || previousChar === "\n") {
        if (lineFormats.list && previousChar === "\n" && nextChar === "\n") {
          if (quill.getLength() - range.index > 2) {
            const endFormatDelta = new Delta().retain(range.index - length - 1).delete(length + 1);
            quill.updateContents(endFormatDelta, Quill.sources.USER);
          } else {
            const endFormatDelta = new Delta().retain(range.index - 1).delete(length + 1)
            const endFormatDelta2 = new Delta().retain(range.index).insert("\n")
            quill.updateContents(endFormatDelta, Quill.sources.USER);
            quill.updateContents(endFormatDelta2, Quill.sources.USER);
            quill.setSelection(range.index + 1, Quill.sources.SILENT);
          }
        } else {
          quill.updateContents(delta, Quill.sources.USER);
          quill.setSelection(range.index + 2, Quill.sources.SILENT);
        }
      } else {
        quill.updateContents(delta, Quill.sources.USER);
        quill.setSelection(range.index + 1, Quill.sources.SILENT);
      }
      quill.focus();

      Object.keys(context.format).forEach((name) => {
        if (lineFormats[name] !== null) {
          return;
        }
        if (Array.isArray(context.format[name])) {
          return;
        }
        if (name === "code" || name === "link") {
          return;
        }
        console.log("FORMATEE")
        quill.format(name, context.format[name], Quill.sources.USER);
      });
    });
    quill.keyboard.bindings[13].push(lastBinding);

    // Now it is the last one
    console.log(quill.keyboard.bindings[13]);
    return;
  });

  exports.lineBreakHandler = lineBreakHandler;
})(window);
