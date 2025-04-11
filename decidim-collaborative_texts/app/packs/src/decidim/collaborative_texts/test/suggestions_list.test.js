/* eslint-disable prefer-reflect */
/* global global, jest */

import Document from "src/decidim/collaborative_texts/document";
import SuggestionsList from "src/decidim/collaborative_texts/suggestions_list";
import Suggestion from "src/decidim/collaborative_texts/suggestion";

describe("SuggestionsList", () => {
  let i18n = {test: "test"};
  let suggestionsUrl = "http://example.com/suggestions";
  let rolloutUrl = "http://example.com/rollout";

  const content = `
    <body>
      <div class="collaborative-texts-alert hidden">
        <div></div>
      </div>

      <div data-collaborative-texts-document="true"
         data-collaborative-texts-suggestions-editor-template="#collaborative-texts-editor-template"
         data-collaborative-texts-suggestions-box-template="#collaborative-texts-suggestions-box-template"
         data-collaborative-texts-suggestions-box-item-template="#collaborative-texts-suggestions-box-item-template"
          data-collaborative-texts-i18n='${JSON.stringify(i18n)}'
          data-collaborative-texts-suggestions-url="${suggestionsUrl}"
          data-collaborative-texts-rollout-url="${rolloutUrl}">
        <h2>This is a collaborative text</h2>
        <p>Some content</p>
        <h2>This is another title</h2>
        <ul><li>More content</li><li>Event more content</li></ul>
      </div>

      <script type="text/template" class="decidim-template" id="collaborative-texts-suggestions-box-template">
        <div data-component="accordion" id="collaborative-texts-box-{{ID}}">
          <button data-controls="panel-box-{{ID}}" aria-label="<%= t("decidim.collaborative_texts.document.toggle") %>" aria-expanded="false">
            <span>
            </span>
            <span>
              <span class="collaborative-texts-suggestions-box-items-count"></span>
            </span>
          </button>
          <div class="collaborative-texts-suggestions-box-items" id="panel-box-{{ID}}" aria-hidden="true"></div>
        </div>
      </script>

      <script type="text/template" class="decidim-template" id="collaborative-texts-suggestions-box-item-template">
        <div class="collaborative-texts-suggestions-box-item-header">
          <div>{{PROFILE}}</div>
          <div class="relative">
            <button class="collaborative-texts-suggestions-box-item-dropdown"
                    id="dropdown-trigger-{{ID}}"
                    data-component="dropdown"
                    data-target="dropdown-menu-{{ID}}"
                    data-auto-close="true">
            </button>

            <div class="collaborative-texts-suggestions-box-header-menu" id="dropdown-menu-{{ID}}" role="menu" aria-labelledby="dropdown-trigger-{{ID}}" aria-hidden="true">
              <ul role="menu">
                <li role="menuitem">
                  <button class="button-apply">Apply</button>
                  <button class="button-restore">Restore</button>
                </li>
              </ul>
            </div>
          </div>
        </div>
        <div class="collaborative-texts-suggestions-box-item-text"></div>
      </script>
    </body>
  `;

  let suggestionsList = null;
  let fetchResult = [
    {
      "changeset": {
        "original": ["some content"],
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

  global.matchMedia = jest.fn(() => ({
    matches: false,
    addListener: jest.fn(),
    removeListener: jest.fn()
  }));

  beforeEach(() => {
    document.body.innerHTML = content;
    suggestionsList = new SuggestionsList(new Document(document.querySelector("[data-collaborative-texts-document]")));
  });

  it("fetches suggestions", async () => {
    const suggestion = suggestionsList.suggestions[0];
    expect(suggestionsList.nodes).toBe(suggestionsList.document.nodes);
    // expect(suggestionsList.doc.innerHTML).toContain("collaborative-texts-suggestions-box");
    // expect(suggestionsList.doc.innerHTML).toContain("This is a replacement");
    // expect(suggestionsList.suggestionsList.length).toBe(1);
    // expect(suggestion).toBeInstanceOf(Suggestion);
    // expect(suggestion.valid).toBe(true);    
    // expect(suggestion.nodes.length).toBe(1);
    // expect(suggestion.firstNode).toBe(suggestionsList.nodes[1]);
    // expect(suggestion.lastNode).toBe(suggestionsList.nodes[1]);
    // expect(suggestion.replace).toEqual(["This is a replacement"]);
    // expect(suggestion.menu).not.toBeNull();
    // expect(suggestion.menuWrapper).not.toBeNull();
    // expect(suggestion.applied).toBe(false);
    // expect(suggestion.i18n).toEqual({apply: "Apply", restore: "Restore"});
    // expect(suggestion.menu.querySelector(".collaborative-texts-button-apply").classList.contains("hidden")).toBe(false);
    // expect(suggestion.menu.querySelector(".collaborative-texts-button-restore").classList.contains("hidden")).toBe(true);
    // expect(suggestion.nodes[0].classList.contains("collaborative-texts-hidden")).toBe(false);
  });

  // it("applies a suggestion", () => {
  //   const suggestion = suggestionsList.suggestions[0];
  //   suggestion.apply();
  //   expect(suggestion.applied).toBe(true);
  //   expect(suggestion.menu.querySelector(".collaborative-texts-button-apply").classList.contains("hidden")).toBe(true);
  //   expect(suggestion.menu.querySelector(".collaborative-texts-button-restore").classList.contains("hidden")).toBe(false);
  //   expect(suggestion.nodes[0].classList.contains("collaborative-texts-hidden")).toBe(true);
  // });

  // it("restores a suggestion", () => {
  //   const suggestion = suggestionsList.suggestions[0];
  //   suggestion.apply();
  //   suggestion.restore();
  //   expect(suggestion.applied).toBe(false);
  //   expect(suggestion.menu.querySelector(".collaborative-texts-button-apply").classList.contains("hidden")).toBe(false);
  //   expect(suggestion.menu.querySelector(".collaborative-texts-button-restore").classList.contains("hidden")).toBe(true);
  //   expect(suggestion.nodes[0].classList.contains("collaborative-texts-hidden")).toBe(false);
  // });
});
