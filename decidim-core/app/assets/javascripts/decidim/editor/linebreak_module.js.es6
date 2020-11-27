((exports) => {
  const Quill = exports.Quill;
  const Parchment = Quill.import("parchment")
  const Delta = Quill.import("delta");
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

    // Replace the default enter handling because we have modified the break element
    // Normally this is the second last handler
    const enterHandlerIndex = quill.keyboard.bindings[13].findIndex((bindDef) => {
      return typeof bindDef.collapsed === "undefined" && typeof bindDef.format === "undefined" && bindDef.shiftKey === null;
    });
    quill.keyboard.bindings[13].splice(enterHandlerIndex, 1);
    const lastBinding = quill.keyboard.bindings[13].pop();
    quill.keyboard.addBinding({ key: 13 }, (range, context) => {
      console.log("range", range);
      console.log("context", context)
      console.log("query", Parchment.query)

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
      const delta = new Delta().retain(range.index).delete(range.length).insert("\n", lineFormats);
      quill.updateContents(delta, Quill.sources.USER);
      const previousChar = quill.getText(range.index - 1, 1);
      if (previousChar === "" || previousChar === "\n") {
        quill.setSelection(range.index + 2, Quill.sources.SILENT);
      } else {
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
    });
    quill.keyboard.bindings[13].push(lastBinding);

    // Now it is the last one
    console.log(quill.keyboard.bindings[13]);
    return;
  });

  exports.lineBreakHandler = lineBreakHandler;
})(window);
