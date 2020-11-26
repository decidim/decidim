((exports) => {
  const Quill = exports.Quill;
  const Delta = Quill.import('delta');
  const Break = Quill.import('blots/break');
  const Embed = Quill.import('blots/embed');
  let icons = Quill.import('ui/icons');
  icons['linebreak'] = '⏎';

  function lineBreakHandler(quill) {
    let range = quill.selection.getRange()[0]
    let currentLeaf = quill.getLeaf(range.index)[0]
    let nextLeaf = quill.getLeaf(range.index + 1)[0]

    quill.insertEmbed(range.index, 'break', true, 'user');

    // Insert a second break if:
    // At the end of the editor, OR next leaf has a different parent (<p>)
    if (nextLeaf === null || (currentLeaf.parent !== nextLeaf.parent)) {
      quill.insertEmbed(range.index, 'break', true, 'user');
    }

    // Now that we've inserted a line break, move the cursor forward
    quill.setSelection(range.index + 1, Quill.sources.SILENT);
  }

  class SmartBreak extends Break {
    length() {
      return 1;
    }

    value() {
      return "\n";
    }

    insertInto(parent, ref) {
      Embed.prototype.insertInto.call(this, parent, ref);
    }
  }

  Quill.register(SmartBreak);
  Quill.register('modules/linebreak', function(quill, _options) {

    quill.getModule("toolbar").addHandler('linebreak', () => {
      lineBreakHandler(quill);
    });


    const initHandler = (delta, _oldDelta, source) => {
      if (source !== "api") {
        return;
      }

      quill.emitter.off("text-change", initHandler);

      if (!delta.ops || delta.ops.length < 1) {
        return;
      }

      const firstOp = delta.ops[0];
      if (!firstOp.insert) {
        return;
      }

      const lastChar = firstOp.insert.substring(firstOp.insert.length - 1, firstOp.insert.length);

      console.log("firstOp.insert", firstOp.insert);
      console.log(`TEST1_${lastChar}_2TEST`);

      const doc = (new DOMParser()).parseFromString(quill.root.innerHTML, "text/html");
      const lastEl = doc.body.children.item(doc.body.children.length - 1);

      if (!lastEl) {
        return;
      }

      if (lastEl && lastEl.children.length === 1 && lastEl.children.item(0).nodeName === "BR") {
        lastEl.remove();

        console.log(delta.ops[0]);
        quill.deleteText(13, 1);

        // console.log(quill.root.innerHTML);
        // console.log(doc.body.innerHTML);
        quill.root.innerHTML = doc.body.innerHTML;
      }
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
    }, (_range, _context) => {
      lineBreakHandler(quill);
    });

    // HAX: make our binding the first one in order to override Quill defaults
    quill.keyboard.bindings[13].unshift(quill.keyboard.bindings[13].pop());
  });

  exports.lineBreakHandler = lineBreakHandler;
})(window);
