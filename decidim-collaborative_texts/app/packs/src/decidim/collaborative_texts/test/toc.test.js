/* global jest */

import Toc from "src/decidim/collaborative_texts/toc";

describe("Toc", () => {
  const content = `
  <body>
    <div class="collaborative-texts-toc" data-collaborative-texts-toc="collaborative-text">
      <ul class="spinner-container"></ul>
    </div>

    <div data-collaborative-texts-document="true"
        data-collaborative-texts-i18n='{}'
        data-collaborative-texts-suggestions-url="#"
        data-collaborative-texts-rollout-url="#">
      <h2 id="node-1">This is a collaborative text</h2>
      <p>Some content</p>
      <div class="collaborative-texts-changes">
        <h2 id="node-2">This is another title</h2>
        <ul><li>More content</li><li>Event more content</li></ul>
      </div>
    </div>
  </body>
`;

  let toc = null;
  let doc = null;

  beforeEach(() => {
    document.body.innerHTML = content;
    doc = document.querySelector("[data-collaborative-texts-document]");
    toc = new Toc(document.querySelector("[data-collaborative-texts-toc]"), doc);
  });

  it("filters text nodes and adds ids", () => {
    expect(toc.headings().length).toBe(2);
    expect(toc.headings()[0].id).toBe("node-1");
    expect(toc.headings()[0].textContent).toBe("This is a collaborative text");
    expect(toc.headings()[1].id).toBe("node-2");
    expect(toc.headings()[1].textContent).toBe("This is another title");
  });

  it("renders the toc", () => {
    toc.render();
    expect(toc.ul.children.length).toBe(2);
    expect(toc.ul.children[0].textContent).toBe("This is a collaborative text");
    expect(toc.ul.children[1].textContent).toBe("This is another title");

  });

  it("scrolls to the heading on click", () => {
    toc.render();
    const entry = toc.ul.children[0];
    const scrollIntoViewMock = jest.fn();
    toc.headings()[0].scrollIntoView = scrollIntoViewMock;
    entry.click();
    expect(window.location.hash).toBe("#node-1");
    expect(toc.headings()[0].scrollIntoView).toHaveBeenCalledWith({ behavior: "smooth" });
  });

  it("binds applied event", () => {
    doc.dispatchEvent(new Event("collaborative-texts:applied"));
    expect(toc.ul.children.length).toBe(2);
  });

  it("binds restored event", () => {
    doc.dispatchEvent(new Event("collaborative-texts:restored"));
    expect(toc.ul.children.length).toBe(2);
  });
});
