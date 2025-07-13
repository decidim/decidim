/* eslint-disable prefer-reflect */
/* global global, jest, process */

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

      <div class="collaborative-texts-manager hidden">
        <div>
          <button data-collaborative-texts-manager-rollout="true">Rollout</button>
          <button data-collaborative-texts-manager-consolidate="true">Consolidate</button>
          <button data-collaborative-texts-manager-cancel="true">Cancel</button>
        </div>
        <div class="collaborative-texts-manager-counters">
          Applied: <span class="collaborative-texts-manager-applied"></span>
          Pending: <span class="collaborative-texts-manager-pending"></span>
        </div>
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
  let doc = null;
  let suggestion = null;
  let firstSuggestion = null;
  let fetchResult = [
    {
      "changeset": {
        "original": ["some content"],
        "replace": ["This is another replacement"],
        "firstNode": 2,
        "lastNode": 2
      },
      "status": "pending",
      "profileHtml": "<div>Profile</div>",
      "summary": "This is another summary"
    }, {
      "changeset": {
        "original": ["some content"],
        "replace": ["This is a replacement"],
        "firstNode": 2,
        "lastNode": 2
      },
      "status": "pending",
      "profileHtml": "<div>Profile</div>",
      "summary": "This is a summary"
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

  global.setTimeout = jest.fn((fn) => {
    fn();
    return 1;
  });
  global.clearTimeout = jest.fn(() => {
    return 1;
  });

  beforeEach(async () => {
    document.body.innerHTML = content;
    doc = new Document(document.querySelector("[data-collaborative-texts-document]"));
    suggestionsList = new SuggestionsList(doc);
    doc.suggestionsList = suggestionsList;
    await new Promise(process.nextTick);
    firstSuggestion = suggestionsList.suggestions[0];
    suggestion = suggestionsList.suggestions[1];
    jest.spyOn(suggestion, "setPosition");
  });

  it("fetches suggestions", () => {
    expect(suggestionsList.nodes).toBe(suggestionsList.document.nodes);
    expect(suggestionsList.doc.innerHTML).toContain("collaborative-texts-suggestions-box");
    expect(suggestionsList.doc.innerHTML).toContain("This is a summary");
    expect(suggestionsList.suggestions.length).toBe(2);
    expect(suggestion).toBeInstanceOf(Suggestion);
    expect(suggestion.valid).toBe(true);
    expect(suggestion.nodes.length).toBe(1);
    expect(suggestion.firstNode).toBe(suggestionsList.nodes[1]);
    expect(suggestion.lastNode).toBe(suggestionsList.nodes[1]);
    expect(suggestion.replace).toEqual(["This is a replacement"]);
    expect(suggestion.applied).toBe(false);
    expect(suggestion.nodes[0].classList.contains("collaborative-texts-hidden")).toBe(false);
    expect(suggestionsList.defaultSuggestions()).not.toContain(suggestion);
    expect(suggestionsList.defaultSuggestions()).toContain(firstSuggestion);
  });

  it("applies a suggestion", () => {
    const spy = jest.spyOn(doc.doc, "dispatchEvent");
    suggestion.apply();
    expect(spy.mock.calls[0][0].type).toBe("collaborative-texts:applied");
    expect(spy.mock.calls[0][0].detail.suggestion).toBe(suggestion);
    expect(suggestion.setPosition).toHaveBeenCalled();

    expect(suggestion.applied).toBe(true);
    expect(suggestion.changesWrapper).toBeInstanceOf(HTMLElement);
    expect(suggestion.item.classList.contains("applied")).toBe(true);
    expect(suggestion.nodes[0].classList.contains("collaborative-texts-hidden")).toBe(true);
    expect(suggestion.changesWrapper.textContent).toBe("This is a replacement");
    expect(suggestionsList.getApplied().length).toBe(1);
    expect(suggestionsList.getPending().length).toBe(1);
    expect(doc.doc.innerHTML).toContain("This is a replacement");
    expect(doc.doc.querySelector(".collaborative-texts-hidden").innerHTML).toContain("Some content");
    expect(suggestionsList.defaultSuggestions()).toContain(suggestion);
    expect(suggestionsList.defaultSuggestions()).not.toContain(firstSuggestion);
  });

  it("restores a suggestion", () => {
    const spy = jest.spyOn(doc.doc, "dispatchEvent");
    suggestion.apply();
    expect(spy.mock.calls[0][0].type).toBe("collaborative-texts:applied");
    expect(spy.mock.calls[0][0].detail.suggestion).toBe(suggestion);
    expect(suggestion.setPosition).toHaveBeenCalled();

    suggestion.restore();
    expect(spy.mock.calls[1][0].type).toBe("collaborative-texts:restored");
    expect(spy.mock.calls[1][0].detail.suggestion).toBe(suggestion);
    expect(suggestion.setPosition).toHaveBeenCalled();


    expect(suggestion.applied).toBe(false);
    expect(suggestion.changesWrapper).toBe(null);
    expect(suggestion.item.classList.contains("applied")).toBe(false);
    expect(suggestion.nodes[0].classList.contains("collaborative-texts-hidden")).toBe(false);
    expect(suggestion.nodes[0].textContent).toBe("Some content");
    expect(suggestionsList.getApplied().length).toBe(0);
    expect(suggestionsList.getPending().length).toBe(2);
    expect(doc.doc.innerHTML).toContain("Some content");
    expect(doc.doc.innerHTML).not.toContain("This is a replacement");
    expect(suggestionsList.defaultSuggestions()).not.toContain(suggestion);
    expect(suggestionsList.defaultSuggestions()).toContain(firstSuggestion);
  });

  it("restores a suggestion and removes the changes wrapper", () => {
    suggestion.apply();
    suggestionsList.restore([]);
    expect(suggestion.applied).toBe(true);
    suggestionsList.restore([suggestion.nodes[0]], [suggestion]);
    expect(suggestion.applied).toBe(true);
    suggestionsList.restore([suggestion.nodes[0]]);
    expect(suggestion.applied).toBe(false);
    expect(suggestionsList.defaultSuggestions()).not.toContain(suggestion);
    expect(suggestionsList.defaultSuggestions()).toContain(firstSuggestion);
  });

  it("highlights a suggestion on mouseover", () => {
    suggestion.highlight();
    expect(suggestion.highlightWrapper).toBeInstanceOf(HTMLElement);
    expect(suggestion.highlightWrapper.textContent).toBe("This is a replacement");
    expect(doc.doc.querySelector(".collaborative-texts-highlight-hidden").innerHTML).toContain("Some content");
    expect(doc.doc.querySelector(".collaborative-texts-highlight").innerHTML).toContain("This is a replacement");
  });

  it("blurs a suggestion on mouseout", () => {
    suggestion.highlight();
    suggestion.blur();
    expect(suggestion.highlightWrapper).toBe(null);
    expect(doc.doc.querySelector(".collaborative-texts-hidden")).toBe(null);
    expect(doc.doc.querySelector(".collaborative-texts-highlight")).toBe(null);
  });
});
