// = require tribute

$(() => {
  const $mentionContainer = $(".js-mentions");
  const nodatafound = $mentionContainer.attr("data-noresults");

  let noMatchTemplate = null
  if (nodatafound) {
    noMatchTemplate = () => `<li>${nodatafound}</li>`;
  }

  // Listener for the event triggered by quilljs
  let cursor = "";
  $mentionContainer.on("quill-position", (event) => {
    if (event.detail !== null) {
      // When replacing the text content after selecting a hashtag, we only need
      // to know the hashtag's start position as that is the point which we want
      // to replace.
      let quill = event.target.__quill;
      if (quill.getText(event.detail.index - 1, 1) === "@") {
        cursor = event.detail.index;
      }
    }
  });

  /* eslint no-use-before-define: ["error", { "variables": false }]*/
  let remoteSearch = function(text, cb) {
    $.post("/api", {query: `{users(wildcard:"${text}") {nickname,name}}`}).

      then((response) => {
        let data = response.data.users || {};
        cb(data)
      }).fail(function() {
        cb([])
      }).always(() => {
      // This function runs Tribute every single time you type something
      // So we must evalute DOM properties after each
        const $parent = $(tribute.current.element).parent();
        $parent.addClass("is-active");

        // We need to move the container to the wrapper selected
        const $tribute = $parent.find(".tribute-container");
        // Remove the inline styles, relative to absolute positioning
        $tribute.removeAttr("style");
      })
  };

  // tribute.js docs - http://github.com/zurb/tribute
  /* global Tribute*/
  let tribute = new Tribute({
    trigger: "@",
    values: function (text, cb) {
      remoteSearch(text, (users) => cb(users));
    },
    positionMenu: true,
    menuContainer: null,
    menuItemLimit: 5,
    fillAttr: "nickname",
    noMatchTemplate: noMatchTemplate,
    lookup: (item) => item.nickname + item.name,
    selectTemplate: function(item) {
      if (typeof item === "undefined") {
        return null;
      }
      if (this.range.isContentEditable(this.current.element)) {
        // Check quill.js
        if ($(this.current.element).hasClass("ql-editor")) {
          let editorContainer = $(this.current.element).parent().get(0);
          let quill = editorContainer.__quill;
          quill.insertText(cursor - 1, `${item.original.nickname} `, Quill.sources.API);
          // cursor position + nickname length + "@" sign + space
          let position = cursor + item.original.nickname.length + 2

          let next = 0;
          if (quill.getLength() > position) {
            next = position
          } else {
            next = quill.getLength() - 1
          }
          // Workaround https://github.com/quilljs/quill/issues/731
          setTimeout(function () {
            quill.setSelection(next, 0);
          }, 500);

          return ""
        }
        return `<span contenteditable="false">${item.original.nickname}</span>`;
      }
      return item.original.nickname;
    },
    menuItemTemplate: function(item) {
      let tpl = `<strong>${item.original.nickname}</strong>&nbsp;<small>${item.original.name}</small>`;
      return tpl;
    }
  });

  let setupEvents = function($element) {
    // DOM manipulation
    $element.on("focusin", (event) => {
      // Set the parent container relative to the current element
      tribute.menuContainer = event.target.parentNode;
    });
    $element.on("focusout", (event) => {
      let $parent = $(event.target).parent();

      if ($parent.hasClass("is-active")) {
        $parent.removeClass("is-active");
      }
    });
    $element.on("input", (event) => {
      let $parent = $(event.target).parent();

      if (tribute.isActive) {
        // We need to move the container to the wrapper selected
        let $tribute = $(".tribute-container");
        $tribute.appendTo($parent);
        // // Remove the inline styles, relative to absolute positioning
        $tribute.removeAttr("style");
        // Parent adaptation
        $parent.addClass("is-active");
      } else {
        $parent.removeClass("is-active");
      }
    });

  };

  setupEvents($mentionContainer);

  // This allows external libraries (like React) to use the component
  // by simply firing and event targeting the element where to attach Tribute
  $(document).on("attach-mentions-element", (event, element) => {
    if (!element) {
      return;
    }
    tribute.attach(element);
    // Due a bug in Tribute, re-add menu to DOM if it has been removed
    // See https://github.com/zurb/tribute/issues/140
    if (tribute.menu && !document.body.contains(tribute.menu)) {
      tribute.range.getDocument().body.appendChild(tribute.menu);
    }
    setupEvents($(element));
  });

  // tribute.attach($mentionContainer);
  // Tribute needs to be attached to the `.ql-editor` element as said at:
  // https://github.com/quilljs/quill/issues/1816
  //
  // For this reason we need to wait a bit for quill to initialize itself.
  setTimeout(function() {
    $mentionContainer.each((index, item) => {
      let $qlEditor = $(".ql-editor", item);
      if ($qlEditor.length > 0) {
        tribute.attach($qlEditor);
      } else {
        tribute.attach(item);
      }
    });
  }, 1000);
});

