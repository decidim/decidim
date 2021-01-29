// import Parchment from 'parchment';
// import Quill from '../core/quill';
// import Module from '../core/module';

((exports) => {
  const Quill = exports.Quill;
  const History = Quill.import("modules/history");

  /**
   * Linebreak module brokes quill's default history class.
   * So here we are moving innerHTML to undo and redo stack
   * instead of deltas.
   */
  class HistoryOverride extends History {
    constructor(quill, options) {
      super(quill, options);
      this.lastRecorded = 0;
      this.ignoreChange = false;
      this.init = false;
      this.quill.emitter.on("editor-ready", () => {
        this.clear();
        const $input = $(this.quill.container).siblings('input[type="hidden"]');
        this.stack.undo.push({content: $input.val() || "", index: this.quill.getLength() - 2 });
        this.lastLength = this.quill.getLength();
      })
      /* eslint-disable max-params */
      this.quill.on(Quill.events.EDITOR_CHANGE, (eventName, delta, oldDelta, source) => {
        if (!delta) {
          return;
        }
        if (!this.init && eventName === "selection-change") {
          this.stack.undo[0].index = delta.index;
        }
        if (eventName !== Quill.events.TEXT_CHANGE || this.ignoreChange) {
          return;
        }

        if (!this.options.userOnly || source === Quill.sources.USER) {
          this.record(delta, oldDelta);
        }
      });
      this.quill.keyboard.addBinding({ key: "Z", shortKey: true }, this.undo.bind(this));
      this.quill.keyboard.addBinding({ key: "Z", shortKey: true, shiftKey: true }, this.redo.bind(this));
      if (/Win/i.test(navigator.platform)) {
        this.quill.keyboard.addBinding({ key: "Y", shortKey: true }, this.redo.bind(this));
      }
    }
    /* eslint-enable max-params */

    change(source, dest) {
      if (this.stack[source].length === 0) {
        return;
      }
      let obj = this.updateStacks(source, dest);
      if (!obj.content) {
        return;
      }
      if (!obj.index) {
        obj.index = 0
      }
      this.lastRecorded = 0;
      this.ignoreChange = true;
      this.quill.setContents(this.quill.clipboard.convert(obj.content));
      this.ignoreChange = false;
      let index = obj.index;
      this.quill.setSelection(index);
    }

    updateStacks(source, dest) {
      if (source === "undo") {
        if (this.stack.undo.length === 1) {
          return this.stack.undo[0]
        }
        this.stack[dest].push(this.stack.undo.pop())
        return this.stack.undo[this.stack.undo.length - 1]
      }
      let content = this.stack.redo.pop();
      this.stack.undo.push(content)
      return content
    }

    record(changeDelta) {
      if (changeDelta.ops.length === 0) {
        return
      } else if (!this.init) {
        this.init = true;
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

    transform() {
      return;
    }
  }
  History.DEFAULTS = {
    delay: 1000,
    maxStack: 100,
    userOnly: true
  };

  exports.Decidim.Editor.HistoryOverride = HistoryOverride
})(window)
