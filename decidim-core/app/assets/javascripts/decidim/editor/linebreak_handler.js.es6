const Parchment = Quill.import("parchment")
const Break = Quill.import("blots/break");
const Embed = Quill.import("blots/embed");

((exports) => {
  const Quill = exports.Quill;
  const Delta = Quill.import("delta");

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

  const addEnterBindings = (quill) => {
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

    // const lastBinding = quill.keyboard.bindings[13].pop();
    const enterHandlerIndex = quill.keyboard.bindings[13].findIndex((bindDef) => {
      return typeof bindDef.collapsed === "undefined" && typeof bindDef.format === "undefined" && bindDef.shiftKey === null;
    });
    // HAX: make our SHIFT+ENTER binding the first one in order to override Quill defaults
    quill.keyboard.bindings[13].splice(enterHandlerIndex, 1);

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

      const previousChar = quill.getText(range.index - 1, 1);
      const nextChar = quill.getText(range.index, 1);
      const delta = new Delta().retain(range.index).delete(range.length).insert("\n", lineFormats);
      // console.log(`nextChar_${nextChar}_nextchar`)
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
        quill.format(name, context.format[name], Quill.sources.USER);
      });
      // console.log("ops", quill.getContents().ops)
    });
    // quill.keyboard.bindings[13].push(lastBinding);

    // Replace the default enter handling because we have modified the break element
    // Normally this is the second last handler
    quill.keyboard.bindings[13].unshift(quill.keyboard.bindings[13].pop());
    // console.log(quill.keyboard.bindings[13]);
    return;
  }

  exports.Decidim.lineBreakHandler = lineBreakHandler;
  exports.Decidim.addEnterBindings = addEnterBindings;
})(window)
