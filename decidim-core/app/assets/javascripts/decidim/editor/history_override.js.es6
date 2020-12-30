// import Parchment from 'parchment';
// import Quill from '../core/quill';
// import Module from '../core/module';

((exports) => {
  const Quill = exports.Quill;
  const Parchment = Quill.import("parchment")
  const History = Quill.import("modules/history");

  class HistoryOverride extends History {
    constructor(quill, options) {
      super(quill, options);
      this.lastRecorded = 0;
      this.ignoreChange = false;
      this.lastChange = "init"
      this.quill.emitter.on("editor-ready", () => {
        this.stack = { undo: [], redo: [] };
        const $input = $(this.quill.container).siblings('input[type="hidden"]');

        this.stack.undo.push($input.val() || "");
        this.lastLength = this.quill.getLength();
      })
      this.quill.on(Quill.events.EDITOR_CHANGE, (eventName, delta, oldDelta, source) => {
        if (eventName !== Quill.events.TEXT_CHANGE || this.ignoreChange) return;
        if (!this.options.userOnly || source === Quill.sources.USER) {
          this.record(delta, oldDelta);
        }
      });
      this.quill.keyboard.addBinding({ key: 'Z', shortKey: true }, this.undo.bind(this));
      this.quill.keyboard.addBinding({ key: 'Z', shortKey: true, shiftKey: true }, this.redo.bind(this));
      if (/Win/i.test(navigator.platform)) {
        this.quill.keyboard.addBinding({ key: 'Y', shortKey: true }, this.redo.bind(this));
      }
    }

    change(source, dest) {
      if (this.stack[source].length === 0) return;
      let content = this.updateStacks(source, dest);
      console.log("undo stack", this.stack["undo"])
      console.log("redo stack", this.stack["redo"])
      if (!content) return;
      console.log("source", source)
      console.log("content", content)
      this.lastRecorded = 0;
      this.ignoreChange = true;
      this.quill.setContents(this.quill.clipboard.convert(content));
      this.ignoreChange = false;
      // let index = getLastChangeIndex(delta[source]);
      let index = 0
      this.quill.setSelection(index);
    }

    updateStacks(source, dest) {
      if (source === "undo") {
        if (this.stack["undo"].length === 1) {
          return this.stack["undo"][0]
        } else {
          this.stack["redo"].push(this.stack["undo"].pop())
          return this.stack["undo"][this.stack["undo"].length - 1]
        }
      }
      let content = this.stack["redo"].pop();
      this.stack["undo"].push(content)
      return content
    }

    clear() {
      this.stack = { undo: [], redo: [] };
    }

    cutoff() {
      this.lastRecorded = 0;
    }

    record(changeDelta, _oldDelta) {
      if (changeDelta.ops.length === 0) {
        console.log("sama delta");
        return
      }
      if (Math.abs(this.lastLength-this.quill.getLength()) < 1) {
        console.log("liian vähä lengthii");
        return;
      }
      this.stack.redo = [];
      this.lastLength = this.quill.getLength();

      // const $input = $(this.quill.container).siblings('input[type="hidden"]');
      // console.log("input.val()", $input.val())
      // console.log("quil.html()", this.quill.container.firstChild.innerHTML)

      console.log("save", this.quill.container.firstChild.innerHTML)
      this.stack.undo.push(this.quill.container.firstChild.innerHTML)
    }

    redo() {
      this.change('redo', 'undo');
    }

    transform(delta) {
      // this.stack.undo.forEach(function(change) {
      //   change.undo = delta.transform(change.undo, true);
      //   change.redo = delta.transform(change.redo, true);
      // });
      // this.stack.redo.forEach(function(change) {
      //   change.undo = delta.transform(change.undo, true);
      //   change.redo = delta.transform(change.redo, true);
      // });
    }

    undo() {
      console.log("UNDO")
      this.change('undo', 'redo');
    }
  }
  History.DEFAULTS = {
    delay: 1000,
    maxStack: 100,
    userOnly: false
  };

  function endsWithNewlineChange(delta) {
    let lastOp = delta.ops[delta.ops.length - 1];
    if (lastOp == null) return false;
    if (lastOp.insert != null) {
      return typeof lastOp.insert === 'string' && lastOp.insert.endsWith('\n');
    }
    if (lastOp.attributes != null) {
      return Object.keys(lastOp.attributes).some(function(attr) {
        return Parchment.query(attr, Parchment.Scope.BLOCK) != null;
      });
    }
    return false;
  }

  function getLastChangeIndex(delta) {
    return 0;
  }

  exports.Decidim.Editor.HistoryOverride = HistoryOverride // { History as default, getLastChangeIndex };
})(window)
