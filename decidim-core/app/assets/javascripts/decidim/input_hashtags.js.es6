// = require tribute

$(() => {
  const $hashtagContainer = $(".js-hashtags");
  const nodatafound = $hashtagContainer.attr("data-noresults");

  // Listener for the event triggered by quilljs
  let cursor = "";
  $hashtagContainer.on("quill-position", function(event) {
    if (event.detail !== null) {
      cursor = event.detail.index;
    }
  });

  /* eslint no-use-before-define: ["error", { "variables": false }]*/
  let remoteSearch = function(text, cb) {
    $.post("/api", {query: `{hashtags(name:${text}) {name}}`}).

      then((response) => {
        let data = response.data.hashtags || {};
        cb(data)
      }).fail(function() {
        cb([])
      }).always(() => {
      // This function runs Tribute every single time you type something
      // So we must evalute DOM properties after each
        const $parent = $(tribute.current.element).parent()
        $parent.addClass("is-active")

        // We need to move the container to the wrapper selected
        const $tribute = $parent.find(".tribute-container");
        // Remove the inline styles, relative to absolute positioning
        $tribute.removeAttr("style");
      })
  };

  // tribute.js docs - http://github.com/zurb/tribute
  /* global Tribute*/
  let tribute = new Tribute({
    trigger: "#",
    values: function (text, cb) {
      remoteSearch(text, (hashtags) => cb(hashtags));
    },
    positionMenu: true,
    menuContainer: null,
    fillAttr: "name",
    noMatchTemplate: () => `<li>${nodatafound}</li>`,
    lookup: (item) => item.name,
    selectTemplate: function(item) {
      if (typeof item === "undefined") {
        return null;
      }
      if (this.range.isContentEditable(this.current.element)) {
        // Check quill.js
        if ($(this.current.element).hasClass("editor-container")) {
          let quill = this.current.element.__quill;
          quill.insertText(cursor - 1, `#${item.original.name} `, Quill.sources.API);
          // cursor position + hashtag length + "#" sign + space
          let position = cursor + item.original.name.length + 2;

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
        return `<span contenteditable="false">#${item.original.name}</span>`;
      }
      return `#${item.original.name}`;
    },
    menuItemTemplate: function(item) {
      let tpl = `<strong>${item.original.name}</strong>`;
      return tpl;
    }
  });

  tribute.attach($hashtagContainer);

  // DOM manipulation
  $hashtagContainer.on("focusin", (event) => {
    // Set the parent container relative to the current element

    tribute.menuContainer = event.target.parentNode;
  });
  $hashtagContainer.on("focusout", (event) => {
    let $parent = $(event.target).parent();

    if ($parent.hasClass("is-active")) {
      $parent.removeClass("is-active");
    }
  });
  $hashtagContainer.on("input", (event) => {
    let $parent = $(event.target).parent();
    $parent.removeAttr("style");

    if (tribute.isActive) {
      // We need to move the container to the wrapper selected
      let $tribute = $(".tribute-container");
      $tribute.removeAttr("style");
      $tribute.appendTo($parent);
      // Remove the inline styles, relative to absolute positioning
      // Parent adaptation
      $parent.addClass("is-active");
    } else {
      $parent.removeClass("is-active");
    }
  });
});
