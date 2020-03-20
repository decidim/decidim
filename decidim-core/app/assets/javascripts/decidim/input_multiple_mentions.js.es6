// = require tribute

const maxRecipients = 9;
let mentionsCount = 0;

/* eslint no-unused-vars: 0 */
const deleteRecipient = (element) => {
  // Remove recipient
  element.remove();
  mentionsCount -= 1;
  // In case mentions container disable, enable again
  if ($(".js-multiple-mentions").prop("disabled")) {
    $(".js-multiple-mentions").prop("disabled", false);
  }
};

$(() => {
  const $multipleMentionContainer = $(".js-multiple-mentions");
  const $multipleMentionRecipientsContainer = $(".js-multiple-mentions-recipients");
  const nodatafound = $multipleMentionContainer.attr("data-noresults");

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
    let query = `{users(filter:{wildcard:"${text}"}){id,nickname,name,avatarUrl,disabledNotifications}}`;
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
  /* eslint multiline-ternary: 0 */
  /* eslint no-ternary: 0 */
  let tribute = new Tribute({
    trigger: "@",
    // avoid overloading the API if the user types too fast
    values: debounce(function (text, cb) {
      remoteSearch(text, (users) => cb(users));
    }, 250),
    positionMenu: true,
    menuContainer: null,
    menuItemLimit: 10,
    fillAttr: "nickname",
    noMatchTemplate: noMatchTemplate,
    lookup: (item) => item.nickname + item.name,
    selectTemplate: function(item) {
      mentionsCount += 1;
      if (mentionsCount >= maxRecipients) {
        $multipleMentionContainer.prop("disabled", true);
      }
      if (typeof item === "undefined") {
        return null;
      }
      // Set recipient profile view
      let recipientLabel = `
        <label style="padding: 0 0 10px 0" onClick="deleteRecipient(this)">
          <img src="${item.original.avatarUrl}" alt="${item.original.name}" height="35" width="35" style="border-radius: 50%;">&nbsp;
          <b>${item.original.name}</b>
          <input type="hidden" name="recipient_id[]" value="${item.original.id}">
        </label>
      `;
      // Append new recipient to DOM
      if (item.original.disabledNotifications === "") {
        $multipleMentionRecipientsContainer.append(recipientLabel);
        $multipleMentionContainer.val("");
      }
      // Clean input
      return "";
    },
    menuItemTemplate: function(item) {
      let disabledElementClass = ((item.original.disabledNotifications === "") ? "" : "class=\"disabled-notifications\"")
      let tpl = `<div ${disabledElementClass}><strong>${item.original.nickname}</strong>&nbsp;<small>${item.original.name}</small>&nbsp;<span class="disabled-notifications-info">${item.original.disabledNotifications}</span></div>`;
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

  // Call only if we have containter to bind events to
  if ($multipleMentionContainer.length) {
    setupEvents($multipleMentionContainer);
  }

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

  // tribute.attach($multipleMentionContainer);
  // Tribute needs to be attached to the `.ql-editor` element as said at:
  // https://github.com/quilljs/quill/issues/1816
  //
  // For this reason we need to wait a bit for quill to initialize itself.
  setTimeout(function() {
    $multipleMentionContainer.each((index, item) => {
      let $qlEditor = $(".ql-editor", item);
      if ($qlEditor.length > 0) {
        tribute.attach($qlEditor);
      } else {
        tribute.attach(item);
      }
    });
  }, 1000);
});
