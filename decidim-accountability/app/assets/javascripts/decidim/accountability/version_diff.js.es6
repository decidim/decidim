/* global JsDiff */

$(() => {
  $(".diff-i18n_html, .diff-i18n").each(function(_index, element) {
    const diffElement = $(element);
    const valueElement = diffElement.find(".diff__value");
    const oldValue = valueElement.data("old-value").replace(/</g, "&lt;").replace(/>/g, "&gt;");
    const newValue = valueElement.data("new-value").replace(/</g, "&lt;").replace(/>/g, "&gt;");

    const diff = JsDiff.diffChars(oldValue, newValue);
    let outputHTML = "";

    diff.forEach(({added, removed, value}) => {
      let color = "";

      if (added) {
        color = "#89ffaa";
      } else if (removed) {
        color = "red";
      }

      if (added || removed) {
        outputHTML += `<span style="background-color: ${color}">${value}</span>`;
      } else {
        outputHTML += value;
      }
    });

    outputHTML = outputHTML.replace(/\n/g, "<br><br>");

    valueElement.html(outputHTML);
  });
})
