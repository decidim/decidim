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
      this.quill.emitter.on("editor-ready", () => {
        this.stack = { undo: [], redo: [] };
        const $input = $(this.quill.container).siblings('input[type="hidden"]');
        this.stack.undo.push({content: $input.val() || "", index: 0 });
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
      let obj = this.updateStacks(source, dest);
      console.log("undo stack", this.stack["undo"])
      console.log("redo stack", this.stack["redo"])
      if (!obj.content) return;
      console.log("source", source)
      console.log("content", obj.content)
      this.lastRecorded = 0;
      this.ignoreChange = true;
      this.quill.setContents(this.quill.clipboard.convert(obj.content));
      this.ignoreChange = false;
      // let index = getLastChangeIndex(delta[source]);
      let index = obj.index;
      this.quill.setSelection(index);
    }

    updateStacks(source, _dest) {
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

      console.log("save", this.quill.container.firstChild.innerHTML)
      this.stack.undo.push({content: this.quill.container.firstChild.innerHTML, index: this.quill.getSelection()})
    }

    redo() {
      this.change('redo', 'undo');
    }

    undo() {
      this.change('undo', 'redo');
    }

    transform(_delta) {
      return;
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
