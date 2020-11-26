((exports) => {
  const Quill = exports.Quill;
  const Delta = Quill.import("delta");
  const Break = Quill.import("blots/break");
  const Embed = Quill.import("blots/embed");
  let icons = Quill.import("ui/icons");
  icons.linebreak = "⏎";

  const lineBreakHandler = (quill) => {
    let range = quill.selection.getRange()[0]
    let currentLeaf = quill.getLeaf(range.index)[0]
    let nextLeaf = quill.getLeaf(range.index + 1)[0]

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

    const initHandler = (delta, _oldDelta, source) => {
      if (source !== "api") {
        return;
      }

      // quill.emitter.off("text-change", initHandler);
      // console.log(delta.ops);

      if (!delta.ops || delta.ops.length < 1) {
        return;
      }

      let lastInsetOpsIndex = 0;
      for (let idx = delta.ops.length - 1; idx >= 0; idx -= 1) {
        if (delta.ops[idx].insert) {
          lastInsetOpsIndex = idx;
          break;
        }
      }
      // console.log("lastInsetOpsIndex", lastInsetOpsIndex)
      const lastInsertOp = delta.ops[lastInsetOpsIndex];
      // console.log("deltaOps", lastInsertOp)
      if (!lastInsertOp.insert) {
        return;
      }

      if (lastInsertOp.insert.lastIndexOf("\n") !== lastInsertOp.insert.length - 1) {
        return;
      }
      // console.log("lastindex", lastInsertOp.insert.lastIndexOf("\n"));


      let lineBreakCount = 0
      for (let idx = 1; idx < lastInsertOp.insert.length; idx += 1) {
        if (lastInsertOp.insert[lastInsertOp.insert.length - idx] !== "\n") {
          break;
        }
        lineBreakCount = idx
      }
      // console.log("quill length", quill.getLength())
      // console.log("linebreakCount", lineBreakCount)
      quill.deleteText(quill.getLength() - lineBreakCount - 2, lineBreakCount);
      // console.log("lastindex", lastInsertOp.insert.lastIndexOf("\n"));
      // console.log("quillOps", quill.getContents().ops[0])
    }
    quill.emitter.on("text-change", initHandler);

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
  });

  exports.lineBreakHandler = lineBreakHandler;
})(window);
