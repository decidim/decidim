/* eslint no-unused-vars: 0 */
import Tribute from "src/decidim/vendor/tribute"

const mentionsInitializer = () => {
  const $mentionContainer = $(".js-mentions");
  const nodatafound = $mentionContainer.attr("data-noresults");

  // The editor implements hashtags functionality by itself so it is not needed
  // to attach tribute to the rich text editor.
  if ($mentionContainer.parent().hasClass("editor")) {
    return;
  }

  let noMatchTemplate = null
  if (nodatafound) {
    noMatchTemplate = () => `<li>${nodatafound}</li>`;
  }

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
    let query = `{users(filter:{wildcard:"${text}"}){nickname,name,avatarUrl,__typename}}`;
    $.post(window.Decidim.config.get("api_path"), {query: query}).
      then((response) => {
        let data = response.data.users || {};
        cb(data)
      }).fail(function() {
        cb([])
      }).always(() => {
      // This function runs Tribute every single time you type something
      // So we must evaluate DOM properties after each
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
      return item.original.nickname;
    },
    menuItemTemplate: function(item) {
      return `
        <img src="${item.original.avatarUrl}" alt="author-avatar">
        <strong>${item.original.nickname}</strong>
        <small>${item.original.name}</small>
      `;
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

  tribute.attach($mentionContainer);
}

$(() => mentionsInitializer());
