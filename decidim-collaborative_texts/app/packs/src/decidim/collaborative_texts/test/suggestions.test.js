import Document from "src/decidim/collaborative_texts/document";
import Suggestions from "src/decidim/collaborative_texts/suggestions";
import Suggestion from "src/decidim/collaborative_texts/suggestion";

describe("Suggestions", () => {
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

  let suggestions = null;
  let fetchResult = [
    {
      "changeset": {
        "replace": ["This is a replacement"],
        "firstNode": 2,
        "lastNode": 2
      },
      "status": "pending"
    }
  ];
  
  global.fetch = jest.fn(() =>
    Promise.resolve({
      json: () => Promise.resolve(fetchResult)
    })
  );

  beforeEach(() => {
    document.body.innerHTML = content;
    suggestions = new Suggestions(new Document(document.querySelector("[data-collaborative-texts-document]")));
  });

  it("fetches suggestions", async () => {
    const suggestion = suggestions.suggestions[0];
    expect(suggestions.nodes).toBe(suggestions.document.nodes);
    expect(suggestions.doc.innerHTML).toContain("collaborative-texts-suggestions-box");
    expect(suggestions.doc.innerHTML).toContain("This is a replacement");
    expect(suggestions.suggestions.length).toBe(1);
    expect(suggestion).toBeInstanceOf(Suggestion);
    expect(suggestion.valid).toBe(true);    
    expect(suggestion.nodes.length).toBe(1);
    expect(suggestion.firstNode).toBe(suggestions.nodes[1]);
    expect(suggestion.lastNode).toBe(suggestions.nodes[1]);
    expect(suggestion.replace).toEqual(["This is a replacement"]);
    expect(suggestion.menu).not.toBeNull();
    expect(suggestion.menuWrapper).not.toBeNull();
    expect(suggestion.applied).toBe(false);
    expect(suggestion.i18n).toEqual({apply: "Apply", restore: "Restore"});
    expect(suggestion.menu.querySelector(".collaborative-texts-button-apply").classList.contains("hidden")).toBe(false);
    expect(suggestion.menu.querySelector(".collaborative-texts-button-restore").classList.contains("hidden")).toBe(true);
    expect(suggestion.nodes[0].classList.contains("collaborative-texts-hidden")).toBe(false);
  });

  it("applies a suggestion", () => {
    const suggestion = suggestions.suggestions[0];
    suggestion.apply();
    expect(suggestion.applied).toBe(true);
    expect(suggestion.menu.querySelector(".collaborative-texts-button-apply").classList.contains("hidden")).toBe(true);
    expect(suggestion.menu.querySelector(".collaborative-texts-button-restore").classList.contains("hidden")).toBe(false);
    expect(suggestion.nodes[0].classList.contains("collaborative-texts-hidden")).toBe(true);
  });

  it("restores a suggestion", () => {
    const suggestion = suggestions.suggestions[0];
    suggestion.apply();
    suggestion.restore();
    expect(suggestion.applied).toBe(false);
    expect(suggestion.menu.querySelector(".collaborative-texts-button-apply").classList.contains("hidden")).toBe(false);
    expect(suggestion.menu.querySelector(".collaborative-texts-button-restore").classList.contains("hidden")).toBe(true);
    expect(suggestion.nodes[0].classList.contains("collaborative-texts-hidden")).toBe(false);
  });
});
