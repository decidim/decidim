/* eslint no-unused-vars: 0 */
import "src/decidim/vendor/tribute"

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

  // Returns a function, that, as long as it continues to be invoked, will not
  // be triggered. The function will be called after it stops being called for
  // N milliseconds
  /* eslint no-invalid-this: 0 */
  /* eslint consistent-this: 0 */
  /* eslint prefer-reflect: 0 */
  const debounce = function(callback, wait) {
    let timeout = null;
    return (...args) => {
      const context = this;
      clearTimeout(timeout);
      timeout = setTimeout(() => callback.apply(context, args), wait);
    };
  }

  /* eslint no-use-before-define: ["error", { "variables": false }]*/
  let remoteSearch = function(text, cb) {
    let query = `{users(filter:{wildcard:"${text}"}){nickname,name,avatarUrl,__typename,...on UserGroup{membersCount}}}`;
    $.post("/api", {query: query}).
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
    // avoid overloading the API if the user types too fast
    values: debounce(function (text, cb) {
      remoteSearch(text, (users) => cb(users));
    }, 250),
    positionMenu: true,
    menuContainer: null,
    allowSpaces: true,
    menuItemLimit: 5,
    fillAttr: "nickname",
    selectClass: "highlight",
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
      let svg = "";
      if (window.Decidim && item.original.__typename === "UserGroup") {
        const iconsPath =  window.Decidim.config.get("icons_path");

        svg = `<span class="is-group">${item.original.membersCount}x <svg class="icon--members icon"><use href="${iconsPath}#icon-members"/></svg></span>`;
      }
      return `<div class="tribute-item ${item.original.__typename}">
      <span class="author__avatar"><img src="${item.original.avatarUrl}" alt="author-avatar"></span>
        <strong>${item.original.nickname}</strong>
        <small>${item.original.name}</small>
        ${svg}
      </div>`;
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

