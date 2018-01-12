/* eslint-disable multiline-ternary, no-ternary */
// require self
$(() => {
  const removeUrlParameter = (url, parameter) => {
    const urlParts = url.split('?');

    if (urlParts.length >= 2) {
      // Get first part, and remove from array
      const urlBase = urlParts.shift();

      // Join it back up
      const queryString = urlParts.join('?');

      const prefix = `${encodeURIComponent(parameter)}=`;
      const parts = queryString.split(/[&;]/g);

      // Reverse iteration as may be destructive
      for (let index = parts.length; index > 0; index -= 1) {
        // Idiom for string.startsWith
        if (parts[index].lastIndexOf(prefix, 0) !== -1) {
          parts.splice(index, 1);
        }
      }

      if (parts.length === 0) {
        return urlBase;
      }

      return `${urlBase}?${parts.join('&')}`;
    }

    return url;
  }

  $(document).on("click.zf.trigger", (event) => {
    const target = `#${$(event.target).data("open")}`;
    const redirectUrl = $(event.target).data("redirectUrl");

    if (target && redirectUrl) {
      $("<input type='hidden' />").
        attr("id", "redirect_url").
        attr("name", "redirect_url").
        attr("value", redirectUrl).
        appendTo(`${target} form`);

      $(`${target} a`).attr("href", (index, href) => {
        const querystring = jQuery.param({"redirect_url": redirectUrl});
        return href + (href.match(/\?/) ? '&' : '?') + querystring;
      });
    }
  });

  $(document).on('closed.zf.reveal', (event) => {
    $("#redirect_url", event.target).remove();
    $("a", event.target).attr("href", (index, href) => {
      if (href && href.indexOf("redirect_url") !== -1) {
        return removeUrlParameter(href, "redirect_url");
      }

      return href;
    });
  });
});
