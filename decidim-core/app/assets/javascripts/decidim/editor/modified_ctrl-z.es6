((exports) => {
  const Quill = exports.Quill;

  let stack = { undo: [], redo: [] };

  const change = (source, dest) => {
    if (stack[source].length === 0) return;
    let delta = stack[source].pop();
    stack[dest].push(delta);
    lastRecorded = 0;
    ignoreChange = true;
    quill.updateContents(delta[source], Quill.sources.USER);
    ignoreChange = false;
    let index = getLastChangeIndex(delta[source]);
    quill.setSelection(index);
  }

  const undo = () => {
    console.log("UNDO")
    change("undo", "redo")
  }

  const ctrlZ = (quill) => {
    quill.keyboard.addBinding({ key: "Z", altKey: null, ctrlKey: true, metaKey: null, shiftKey: null }, (range, context) => {
      undo();
    })

    // Put this backspace binding to second (after backspce_offset1 it's going to be third)
    console.log("bindings", quill.keyboard.bindings[90])
    quill.keyboard.bindings[90].unshift(quill.keyboard.bindings[90].pop());
  }

  exports.Decidim.Editor.ctrlZ = ctrlZ;
})(window)
