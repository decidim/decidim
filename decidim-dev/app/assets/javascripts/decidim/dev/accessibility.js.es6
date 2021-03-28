// = require axe-core/axe.min.js

((exports) => {
  const { icon } = exports.Decidim;
  const axe = exports.axe;

  const positionIndicators = () => {
    $(".decidim-accessibility-indicator").each((_i, el) => {
      const $indicator = $(el);
      const $target = $indicator.data("accessibility-target");

      $indicator.css({
        top: $target.offset().top - 30,
        left: $target.offset().left - 30
      });
    });
  };

  const moveScreenTo = ($target) => {
    // Scroll the view where the indicator is visible
    const targetTop = $target.offset().top;
    const screenHeight = $(window).height();
    const screenTop = $(window).scrollTop();
    const screenBottom = screenTop + screenHeight;
    if (targetTop < screenTop || targetTop > screenBottom) {
      $(window).scrollTop(targetTop - Math.round(screenHeight / 2));
    }

    // Scroll horizontally so that the element is visible (240 is the
    // accessibility sidebar width).
    const targetLeft = $target.offset().left;
    const screenWidth = $(window).width() - 240;
    const screenLeft = $(window).scrollLeft() + 240;
    const screenRight = screenLeft + screenWidth;
    if (targetLeft < screenLeft || targetLeft > screenRight) {
      $(window).scrollLeft(targetLeft - Math.round(screenWidth / 2));
    }
  };

  $(() => {
    const icons = {
      success: icon("check"),
      violation: icon("warning")
    }
    const $badge = $(`
      <div lang="en" class="decidim-accessibility-badge" tabindex="0" aria-label="Toggle accessibility report">
        <div class="decidim-accessibility-title">WAI WCAG</div>
        <div class="decidim-accessibility-info"></div>
      </div>
    `);
    const $report = $('<div lang="en" class="decidim-accessibility-report"></div>');

    let resizeTimeout = null;
    $(window).on("resize", () => {
      clearTimeout(resizeTimeout);
      resizeTimeout = setTimeout(() => {
        positionIndicators();
      }, 500);
    });

    $badge.on("click", () => {
      $("body").toggleClass("decidim-accessibility-report-open");
      positionIndicators();
    });

    axe.run().then((results) => {
      $("body").prepend($report).prepend($badge);

      if (results.violations.length < 1) {
        $badge.addClass("decidim-accessibility-success");
        $(".decidim-accessibility-info", $badge).append(icons.success);
        $report.append(`
          <div class="decidim-accessibility-report-item">
            <div class="decidim-accessibility-report-item-title">
              No accessibility violations found
            </div>
          </div>
        `);
        return;
      }

      $badge.addClass("decidim-accessibility-violation");
      $(".decidim-accessibility-info", $badge).append(icons.violation).append(`
        <span class="decidim-accessibility-info-amount">
          ${results.violations.length}
        </span>
      `);

      results.violations.forEach((violation) => {
        const $item = $(`
          <div class="decidim-accessibility-report-item">
            <div class="decidim-accessibility-report-item-title">
              ${violation.id} - ${violation.help}
            </div>
            <div class="decidim-accessibility-report-item-description">
              <div>Impact: ${violation.impact}</div>
              <div>
                ${violation.description}
              </div>
              <div class="decidim-accessibility-report-item-nodes">
                Nodes:
                <ul></ul>
              </div>
            </div>
          </div>
        `);
        const $violationNodes = $("<ul></ul>");
        $(".decidim-accessibility-report-item-nodes", $item).append($violationNodes);

        violation.nodes.forEach((node) => {
          node.target.forEach((target) => {
            // The selectors can have IDs starting with numbers which may not
            // be correctly indicated by axe. E.g. if the selector is `#123aa`,
            // axe might report it as `#\31 23aa`. It always adds `#\3` and a
            // space after the following number.
            const selector = target.replace(/#\\3([0-9]) /g, "#$1")
            const $target = $(selector);
            const $indicator = $(`
              <div class="decidim-accessibility-indicator" aria-hidden="true">${icons.violation}</div>
            `);
            $indicator.data("accessibility-target", $target);
            $target.data("accessibility-indicator", $indicator);
            $target.attr("data-accessibility-violation", true);
            $("body").append($indicator);

            const $link = $(`<a href="#">${selector}</a>`);
            $link.data("accessibility-target", $target);

            $violationNodes.append($("<li></li>").append($link));

            $indicator.on("click", () => {
              clearTimeout($item.data("blink-timeout"));
              clearTimeout($link.data("blink-timeout"));

              $item.addClass("decidim-accessibility-report-item-blink");
              $item.data("blink-timeout", setTimeout(() => {
                $item.removeClass("decidim-accessibility-report-item-blink");
              }, 1000));
              $link.addClass("decidim-accessibility-report-item-nodes-item-blink");
              $link.data("blink-timeout", setTimeout(() => {
                $link.removeClass("decidim-accessibility-report-item-nodes-item-blink");
              }, 1000));
            });
          });
        });

        $(".decidim-accessibility-report-item-nodes a", $item).on("click", (ev) => {
          ev.preventDefault();
          const $target = $(ev.target).data("accessibility-target");
          const $indicator = $target.data("accessibility-indicator");
          clearTimeout($indicator.data("blink-timeout"));

          moveScreenTo($target);

          setTimeout(() => {
            // From base color to blink color (1s)
            $indicator.addClass("decidim-accessibility-indicator-blink")
            $target.attr("data-accessibility-violation", "blink");

            // From blink color to base color (1s)
            $indicator.data("blink-timeout", setTimeout(() => {
              $indicator.removeClass("decidim-accessibility-indicator-blink");
              $target.attr("data-accessibility-violation", true);
            }, 1000));
          }, 10);
        });

        $report.append($item);
      });
    });
  });
})(window);
