// = require tribute

$(() => {
  const $mentionContainer = $(".js-mentions");
  const nodatafound = $mentionContainer.attr("data-noresults");
  const sources = [];

  // EXAMPLE DATA
  // tag & name properties are mandatory
  //
  // const sources = [{
  //     "tag": "barrera",
  //     "name": "Collins Franklin",
  //   },
  //   {
  //     "tag": "woods",
  //     "name": "Nadine Buck",
  //   }]

  // Listener for the event triggered by quilljs
  let cursor = "";
  $mentionContainer.on("quill-position", function(event) {
    cursor = event.detail.index;
  });

  // tribute.js docs - http://github.com/zurb/tribute
  /* global Tribute*/
  let tribute = new Tribute({
    values: sources,
    positionMenu: false,
    menuContainer: null,
    fillAttr: "tag",
    noMatchTemplate: () => `<li>${nodatafound}</li>`,
    lookup: (item) => item.tag + item.name,
    selectTemplate: function(item) {
      if (typeof item === "undefined") {
        return null;
      }
      if (this.range.isContentEditable(this.current.element)) {
        // Check quill.js
        if ($(this.current.element).hasClass("editor-container")) {
          let quill = this.current.element.__quill;
          quill.insertText(cursor - 1, `@${item.original.tag} `, Quill.sources.API);
          // cursor position + nickname length + "@" sign + space
          let position = cursor + item.original.tag.length + 2;

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
        return `<span contenteditable="false">@${item.original.tag}</span>`;
      }
      return `@${item.original.tag}`;
    },
    menuItemTemplate: function(item) {
      let tpl = `<strong>${item.original.tag}</strong>&nbsp;<small>${item.original.name}</small>`;
      return tpl;
    }
  });

  tribute.attach($mentionContainer);

  // DOM manipulation
  $mentionContainer.on("focusin", (event) => {
    // Set the parent container relative to the current element
    tribute.menuContainer = event.target.parentNode;
  });
  $mentionContainer.on("focusout", (event) => {
    let $parent = $(event.target).parent();

    if ($parent.hasClass("is-active")) {
      $parent.removeClass("is-active");
    }
  });
  $mentionContainer.on("input", (event) => {
    let $parent = $(event.target).parent();

    if (tribute.isActive) {
      // We need to move the container to the wrapper selected
      let $tribute = $(".tribute-container");
      $tribute.appendTo($parent);
      // Remove the inline styles, relative to absolute positioning
      $tribute.removeAttr("style");
      // Parent adaptation
      $parent.addClass("is-active");
    } else {
      $parent.removeClass("is-active");
    }
  });
});
