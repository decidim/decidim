((exports) => {
  const excludeClasses = [
    "card--list__data__icon",
    "footer-social__icon"
  ];
  const excludeRel = [
    "license",
    "decidim"
  ];

  $(document).ready(function () {
    const { icon } = exports.Decidim;

    $('a[target="_blank"]').each((_i, elem) => {
      const $link = $(elem);

      if (excludeClasses.some((cls) => $link.hasClass(cls))) {
        return;
      }
      if (excludeRel.some((rel) => $link.attr("rel") === rel)) {
        return;
      }

      $link.append(`&nbsp;${icon("external-link")}`);
    });
  });
})(window);
