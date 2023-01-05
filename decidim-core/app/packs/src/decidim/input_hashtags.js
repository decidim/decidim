/* eslint no-unused-vars: 0 */
import Tribute from "src/decidim/vendor/tribute"

$(() => {
  const $hashtagContainer = $(".js-hashtags");
  const nodatafound = $hashtagContainer.attr("data-noresults");

  // The editor implements hashtags functionality by itself so it is not needed
  // to attach tribute to the rich text editor.
  if ($hashtagContainer.parent().hasClass("editor")) {
    return;
  }

  let noMatchTemplate = null
  if (nodatafound) {
    noMatchTemplate = () => `<li>${nodatafound}</li>`;
  }

  /* eslint no-use-before-define: ["error", { "variables": false }]*/
  let remoteSearch = function(text, cb) {
    $.post("/api", {query: `{hashtags(name:"${text}") {name}}`}).

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
    noMatchTemplate: noMatchTemplate,
    lookup: (item) => item.name,
    selectTemplate: function(item) {
      if (typeof item === "undefined") {
        return null;
      }
      return `#${item.original.name}`;
    },
    menuItemTemplate: function(item) {
      let tpl = `<strong>${item.original.name}</strong>`;
      return tpl;
    }
  });

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
});
