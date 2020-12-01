const Parchment = Quill.import("parchment")
const Break = Quill.import("blots/break");
const Embed = Quill.import("blots/embed");

((exports) => {
  const Quill = exports.Quill;
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
    // const range = quill.selection.getRange()[0];
    const currentLeaf = quill.getLeaf(range.index)[0];
    const nextLeaf = quill.getLeaf(range.index + 1)[0];
    // const format = quill.getFormat(range)
    // console.log("format", format)
    // console.log("context", context)


    quill.insertEmbed(range.index, "break", true, "user");
    quill.formatText(range.index + 1, "bold", true)
    // const delta = new Delta().retain(range.index).insert({"break": true}).retain(0, format)
    // quill.updateContents(delta, Quill.sources.USER);

    // Insert a second break if:
    // At the end of the editor, OR next leaf has a different parent (<p>)
    if (nextLeaf === null || (currentLeaf.parent !== nextLeaf.parent)) {
      quill.insertEmbed(range.index, "break", true, "user");
      // quill.formatText(range.index + 1, "bold", true)
      // quill.updateContents(delta, Quill.sources.USER);
    }

    quill.format(name, context.format[name], "user");
    // Now that we've inserted a line break, move the cursor forward
    quill.setSelection(range.index + 1, Quill.sources.SILENT);

    const lineFormats = getLineFormats(context)
    continueFormats(quill, context, lineFormats)
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
    }, (range, context) => {
      lineBreakHandler(quill, range, context);
    });

    const enterHandlerIndex = quill.keyboard.bindings[13].findIndex((bindDef) => {
      return typeof bindDef.collapsed === "undefined" && typeof bindDef.format === "undefined" && bindDef.shiftKey === null;
    });
    // HAX: make our SHIFT+ENTER binding the first one in order to override Quill defaults
    quill.keyboard.bindings[13].splice(enterHandlerIndex, 1);

    quill.keyboard.addBinding({ key: 13, shiftKey: false }, (range, context) => {
      console.log("ops before", quill.getContents().ops)
      const lineFormats = getLineFormats(context)
      const previousChar = quill.getText(range.index - 1, 1);
      const nextChar = quill.getText(range.index, 1);
      const delta = new Delta().retain(range.index).insert("\n", lineFormats);
      // console.log(`nextChar_${nextChar}_nextchar`)
      if (previousChar === "" || previousChar === "\n") {
        if (lineFormats.list && nextChar === "\n") {
          if (quill.getLength() - range.index > 2) {
            const endFormatDelta = new Delta().retain(range.index - length - 1).delete(length + 1);
            quill.updateContents(endFormatDelta, Quill.sources.USER);
          } else {
            // Delete empty list item and end the list
            const endFormatDelta = new Delta().retain(range.index - 1).delete(length + 1)
            const endFormatDelta2 = new Delta().retain(range.index).insert("\n\n\n")
            quill.updateContents(endFormatDelta, Quill.sources.USER);
            quill.updateContents(endFormatDelta2, Quill.sources.USER);
            quill.setSelection(range.index + 1, Quill.sources.SILENT);
          }
        } else {
          console.log("DEBUG5")
          console.log(`previousChar${previousChar}_previousChar`)
          console.log(`nextChar_${nextChar}_nextChar`)
          console.log("context.offset", context.offset)
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

      console.log("ops after", quill.getContents().ops)
      continueFormats(quill, context, lineFormats)
    });
    // const lastBinding = quill.keyboard.bindings[13].pop();
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
