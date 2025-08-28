/* global global, jest */

import Document from "src/decidim/collaborative_texts/document";
import SuggestionsList from "src/decidim/collaborative_texts/suggestions_list";

describe("Document", () => {
  let i18n = {test: "test"};
  let suggestionsUrl = "http://example.com/suggestions";
  let rolloutUrl = "http://example.com/rollout";

  const content = `
    <body>
      <div class="collaborative-texts-alert hidden">
        <div></div>
      </div>

      <div data-collaborative-texts-document="true"
          data-collaborative-texts-i18n='${JSON.stringify(i18n)}'
          data-collaborative-texts-suggestions-url="${suggestionsUrl}"
          data-collaborative-texts-rollout-url="${rolloutUrl}">
        <h2>This is a collaborative text</h2>
        <p>Some content</p>
        <h2>This is another title</h2>
        <ul><li>More content</li><li>Event more content</li></ul>
      </div>
    </body>
  `;

  let doc = null;
  let fetchResult = [];

  global.fetch = jest.fn(() =>
    Promise.resolve({
      json: () => Promise.resolve(fetchResult)
    })
  );

  beforeEach(() => {
    document.body.innerHTML = content;
    doc = new Document(document.querySelector("[data-collaborative-texts-document]"));
  });

  it("Filters text nodes and adds ids", () => {
    expect(doc.fetchSuggestions().suggestionsList).toBeInstanceOf(SuggestionsList);
    expect(doc.fetchSuggestions().suggestionsList.document).toBe(doc);
    expect(doc.nodes.length).toBe(4);
    expect(doc.nodes[0].id).toBe("ct-node-1");
    expect(doc.nodes[0].textContent).toBe("This is a collaborative text");
    expect(doc.nodes[1].id).toBe("ct-node-2");
    expect(doc.nodes[1].textContent).toBe("Some content");
    expect(doc.nodes[2].id).toBe("ct-node-3");
    expect(doc.nodes[2].textContent).toBe("This is another title");
    expect(doc.nodes[3].id).toBe("ct-node-4");
    expect(doc.nodes[3].childNodes[0].textContent).toBe("More content");
    expect(doc.nodes[3].childNodes[1].textContent).toBe("Event more content");
  });

  it("Shows the alert", () => {
    doc.alert("This is a test");
    expect(doc.alertWrapper.classList.contains("hidden")).toBe(false);
    expect(doc.alertDiv.textContent).toBe("This is a test");
  });

  it("enables suggestions", () => {
    expect(doc.active).toBe(true);
    doc.enableSuggestions();
    window.document.dispatchEvent(new Event("selectstart"));
    expect(doc.selecting).toBe(true);
    window.document.dispatchEvent(new Event("mouseup"));
    expect(doc.selecting).toBe(false);
  });

  describe("when disabled", () => {
    beforeEach(() => {
      document.body.innerHTML = '<div class="collaborative-texts-alert"></div><div data-collaborative-texts-document="false" data-collaborative-texts-i18n="{}"></div>';
      doc = new Document(document.querySelector("[data-collaborative-texts-document]"));
    });

    it("disables suggestions", () => {
      expect(doc.active).toBe(false);
    });
  });
});
