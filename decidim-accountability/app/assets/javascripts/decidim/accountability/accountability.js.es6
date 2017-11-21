// = require_self

$(() => {
  // Show category list on click when we are on a small scren
  if ($(window).width() < 768) {
    $('.category--section').click((event) => {
      $(event.currentTarget).next('.category--elements').toggleClass('active');
    });
  }

  $(".diff-i18n_html").each(function() {
    const diffElement = $(this);
    const oldElement = diffElement.find(".removal .diff__value");
    const oldValue = oldElement.html();
    const newElement = diffElement.find(".addition .diff__value");
    const newValue = newElement.html();

    const diff = JsDiff.diffChars(oldValue, newValue);
    let outputHTML = "";
    diff.forEach(({added, removed, value}) => {
      const color = added ? '#89ffaa' : removed ? 'red' : '';
      outputHTML += `<span style="background-color: ${color}">${value}</span>`;
    });
    console.log(diff);
    oldElement.html(outputHTML);
    newElement.html(outputHTML);
  });
})
