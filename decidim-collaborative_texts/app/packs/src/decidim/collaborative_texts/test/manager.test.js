/* eslint-disable prefer-reflect */
/* global global, jest, process */

import Manager from "src/decidim/collaborative_texts/manager";

// Create the configuration object to make the configurations available for the tests
window.Decidim = {}
class DummyDialog {
  constructor(element) { this.element = element; }

  open() { this.element.dataset.dialogOpen = true; }

  close() { this.element.dataset.dialogOpen = null; }
}
describe("Manager", () => {
  const content = `
  <body>
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

    <div data-collaborative-texts-document="true"
        data-collaborative-texts-i18n='{}'
        data-collaborative-texts-suggestions-url="#"
        data-collaborative-texts-rollout-url="rolloutUrl">
      <h2 id="node-1">This is a collaborative text</h2><p>Some content</p>
      <div class="collaborative-texts-ignored"><h2>Ignored content</h2></div>
      <div class="collaborative-texts-changes"><h2 id="node-2">This is another title</h2><ul><li>More content</li><li>Event more content</li></ul></div>
    </div>

    <div id="confirm-modal" data-dialog="confirm-modal">
      <div id="confirm-modal" data-dialog="confirm-modal">
        <div id="confirm-modal-content">
          <div data-dialog-container>
            <div data-confirm-modal-content></div>
          </div>
          <div data-dialog-actions>
            <button data-confirm-cancel data-dialog-close="confirm-modal">Cancel</button>
            <button data-confirm-ok>Ok</button>
          </div>
        </div>
      </div>
    </div>
  </body>
`;

  let manager = null;
  let doc = null;
  let suggestions = [
    {
      id: 1,
      title: "Suggestion 1",
      status: "pending",
      restore: jest.fn()
    },
    {
      id: 2,
      title: "Suggestion 2",
      status: "applied",
      restore: jest.fn()
    }
  ];

  const fetchResult = {
    redirect: "#redirect-somewhere"
  }
  global.fetch = jest.fn(() =>
    Promise.resolve({
      ok: true,
      json: () => Promise.resolve(fetchResult)
    })
  );

  beforeEach(() => {
    window.Decidim.currentDialogs = {
      "confirm-modal": new DummyDialog(document.querySelector("#confirm-modal"))
    };

    document.body.innerHTML = content;
    delete global.window.location;
    global.window = Object.create(window);
    global.window.location = {
      href: "test-url"
    };

    doc = {
      doc: document.querySelector("[data-collaborative-texts-document]"),
      suggestionsList: {
        suggestions: suggestions,
        getApplied: () => {
          return suggestions.filter((suggestion) => suggestion.status === "applied");
        },
        getPending: () => {
          return suggestions.filter((suggestion) => suggestion.status === "pending");
        }
      },
      i18N: {
        rolloutConfirm: "Confirm rollout",
        consolidateConfirm: "Confirm consolidate"
      }
    }
    manager = new Manager(doc);
  });

  it("shows the manager", () => {
    manager.show();
    expect(manager.div.classList.contains("hidden")).toBe(false);
  });

  it("hides the manager", () => {
    manager.hide();
    expect(manager.div.classList.contains("hidden")).toBe(true);
  });

  it("updates the counters", () => {
    manager.updateCounters(1, 2);
    expect(manager.counters.applied[0].textContent).toBe("1");
    expect(manager.counters.pending[0].textContent).toBe("2");
  });

  it("cancels the suggestions", () => {
    manager.cancel();
    expect(suggestions[0].restore).toHaveBeenCalled();
    expect(suggestions[1].restore).toHaveBeenCalled();
    expect(manager.div.classList.contains("hidden")).toBe(true);
  });

  it("gets a new body with applied changes", () => {
    const cleanedBody = manager.cleanBody();
    expect(cleanedBody).toBe("<h2 id=\"node-1\">This is a collaborative text</h2><p>Some content</p><h2 id=\"node-2\">This is another title</h2><ul><li>More content</li><li>Event more content</li></ul>");
  });

  it("rollouts the suggestions", async () => {
    const rolloutButton = manager.rolloutButton;
    rolloutButton.click();
    window.document.querySelector("[data-confirm-ok]").click();
    await new Promise(process.nextTick);

    expect(global.location.href).toBe(fetchResult.redirect);
  });
});
