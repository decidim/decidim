// import Parchment from 'parchment';
// import Quill from '../core/quill';
// import Module from '../core/module';

((exports) => {
  const Quill = exports.Quill;
  const History = Quill.import("modules/history");

  class HistoryOverride extends History {
    constructor(quill, options) {
      super(quill, options);
      this.lastRecorded = 0;
      this.ignoreChange = false;
      this.quill.emitter.on("editor-ready", () => {
        this.stack = { undo: [], redo: [] };
        const $input = $(this.quill.container).siblings('input[type="hidden"]');
        this.stack.undo.push({content: $input.val() || "", index: this.quill.getLength()-2 });
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
      if (!obj.content) return;
      if (!obj.index) obj.index = 0
      this.lastRecorded = 0;
      this.ignoreChange = true;
      this.quill.setContents(this.quill.clipboard.convert(obj.content));
      this.ignoreChange = false;
      let index = obj.index;
      this.quill.setSelection(index);
    }

    updateStacks(source, _dest) {
      if (source === "undo") {
        if (this.stack.undo.length === 1) {
          return this.stack.undo[0]
        } else {
          this.stack.redo.push(this.stack.undo.pop())
          return this.stack.undo[this.stack.undo.length - 1]
        }
      }
      let content = this.stack.redo.pop();
      this.stack.undo.push(content)
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
        return
      }
      this.stack.redo = [];
      let timestamp = Date.now();
      // Should not return after length check, because after linebreak a keypress replaces invisible characters with
      // visible characters.
      // For example: <br><br></p> -> [press X] -> <br>X</p>.
      if (Math.abs(this.lastLength === this.quill.getLength()) || this.lastRecorded + this.options.delay > timestamp) {
        if (this.stack.undo.length > 1) {
          this.stack.undo.pop();
        }
      } else {
        this.lastLength = this.quill.getLength();
        if (this.lastRecorded + this.options.delay <= timestamp) {
          this.lastRecorded = timestamp;
        }
      }
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
    userOnly: true
  };

  exports.Decidim.Editor.HistoryOverride = HistoryOverride // { History as default, getLastChangeIndex };
})(window)
