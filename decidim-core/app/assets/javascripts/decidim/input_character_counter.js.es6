((exports) => {
  const COUNT_KEY = "%count%";
  const DEFAULT_MESSAGES = {
    charactersAtLeast: {
      one: `at least ${COUNT_KEY} character`,
      other: `at least ${COUNT_KEY} characters`
    },
    charactersLeft: {
      one: `${COUNT_KEY} character left`,
      other: `${COUNT_KEY} characters left`
    }
  };
  let MESSAGES = DEFAULT_MESSAGES;

  class InputCharacterCounter {
    static configureMessages(messages) {
      MESSAGES = exports.$.extend(DEFAULT_MESSAGES, messages);
    }

    constructor(input) {
      this.$input = input;
      this.$target = exports.$(this.$input.data("remaining-characters"));
      this.minCharacters = parseInt(this.$input.attr("minlength"), 10);
      this.maxCharacters = parseInt(this.$input.attr("maxlength"), 10);

      if (this.$target.length < 1) {
        let targetId = null;
        if (this.$input.attr("id") && this.$input.attr("id").length > 0) {
          targetId = `${this.$input.attr("id")}_characters`;
        } else {
          targetId = `characters_${Math.random().toString(36).substr(2, 9)}`;
        }

        this.$target = $(`<span id="${targetId}" class="form-input-extra-before" />`)

        // If input is a hidden for WYSIWYG editor add it at the end
        if (this.$input.parent().is(".editor")) {
          this.$input.parent().after(this.$target);
        }
        // Prefix and suffix columns are wrapped in columns, so put the
        // character counter before that.
        else if (
          this.$input.parent().is(".columns") &&
          this.$input.parent().parent().is(".row")
        ) {
          this.$input.parent().parent().after(this.$target);
        } else {
          this.$input.after(this.$target);
        }
      }

      if (this.$target.length > 0 && (this.maxCharacters > 0 || this.minCharacters > 0)) {
        this.bindEvents();
      }
    }

    bindEvents() {
      // In WYSIWYG editors (Quill) we need to find the active editor from the
      // DOM node. Quill has the experimental "find" method that should work
      // fine in this case
      if (Quill && this.$input.parent().is(".editor")) {
        // Wait until the next javascript loop so Quill editors are created
        setTimeout(() => {
          const editor = Quill.find(this.$input.siblings(".editor-container")[0]);
          editor.on("text-change", () => {
            this.updateStatus();
          });
        })
      }
      this.$input.on("keyup", () => {
        this.updateStatus();
      });
      this.updateStatus();
    }

    updateStatus() {
      const numCharacters = this.$input.val().length;
      const showMessages = [];

      if (this.minCharacters > 0) {
        let message = MESSAGES.charactersAtLeast.other;
        if (this.minCharacters === 1) {
          message = MESSAGES.charactersAtLeast.one;
        }
        showMessages.push(message.replace(COUNT_KEY, this.minCharacters));
      }

      if (this.maxCharacters > 0) {
        const remaining = this.maxCharacters - numCharacters;
        let message = MESSAGES.charactersLeft.other;
        if (remaining === 1) {
          message = MESSAGES.charactersLeft.one;
        }
        showMessages.push(message.replace(COUNT_KEY, remaining));
      }

      this.$target.text(showMessages.join(", "));
    }
  }

  exports.Decidim = exports.Decidim || {};
  exports.Decidim.InputCharacterCounter = InputCharacterCounter;

  exports.$(() => {
    exports.$("input[type='text'], textarea, .editor>input[type='hidden']").each((_i, elem) => {
      const $input = exports.$(elem);

      if (!$input.is("[minlength]") && !$input.is("[maxlength]")) {
        return;
      }

      $input.data("remaining-characters-counter", new InputCharacterCounter($input));
    });
  });
})(window);
