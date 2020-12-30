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
      console.log("stack size", this.stack[source].length)
      let content = this.stack[source].pop();
      this.stack[dest].push(content);
      if (content === $(this.quill.container).siblings('input[type="hidden"]').val()) content = this.stack[source].pop();
      if (!content) return;
      console.log("content", content)
      this.lastRecorded = 0;
      this.ignoreChange = true;

      this.quill.setContents(this.quill.clipboard.convert(content));
      this.ignoreChange = false;
      // let index = getLastChangeIndex(delta[source]);
      let index = 0
      this.quill.setSelection(index);
    }

    clear() {
      this.stack = { undo: [], redo: [] };
    }

    cutoff() {
      this.lastRecorded = 0;
    }

    record(changeDelta, _oldDelta) {
      if (changeDelta.ops.length === 0) return;
      if (this.lastLength === this.quill.getLength()) return;
      this.stack.redo = [];
      this.lastLength = this.quill.getLength();

      const $input = $(this.quill.container).siblings('input[type="hidden"]');
      console.log("save", $input.val())
      this.stack.undo.push($input.val())
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
