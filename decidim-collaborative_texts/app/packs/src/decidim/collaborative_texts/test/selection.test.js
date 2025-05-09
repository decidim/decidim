/* global global, jest */

import Document from "src/decidim/collaborative_texts/document";
import Selection from "src/decidim/collaborative_texts/selection";
import Editor from "src/decidim/collaborative_texts/editor";

describe("Selection", () => {
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

      <script type="text/template" class="decidim-template" id="collaborative-texts-editor-template">
        <div class="collaborative-texts-editor-header">
          <button class="collaborative-texts-button-cancel">Cancel</button>
        </div>
        <div class="collaborative-texts-editor-profile">Profile</div>
        <div class="collaborative-texts-editor-container"></div>
        <div class="collaborative-texts-editor-menu">
          <button class="collaborative-texts-button-save" disabled>Send suggestion</button>
        </div>
      </script>
  </body>
  `;

  let doc = null;
  let selection = null;
  global.document.getSelection = jest.fn(() => ({
    rangeCount: 1,
    getRangeAt: jest.fn(() => ({
      intersectsNode: jest.fn((node) => node === doc.nodes[1]),
      commonAncestorContainer: {
        closest: jest.fn(() => null)
      }
    })),
    removeAllRanges: jest.fn(),
    addRange: jest.fn(),
    focusNode: null,
    anchorNode: null
  }));
  let fetchResult = [];
  global.fetch = jest.fn(() =>
    Promise.resolve({
      json: () => Promise.resolve(fetchResult),
      ok: true
    })
  );
  beforeEach(async () => {
    document.body.innerHTML = content;
    doc = new Document(document.querySelector("[data-collaborative-texts-document]"));
    // await new Promise(process.nextTick);
    selection = new Selection(doc);
  });

  it("Creates a selection", () => {
    expect(selection.blocked).toBe(false);
    expect(selection.doc).toBe(doc);
    selection.detectNodes();
    expect(selection.nodes.length).toBe(2);
    expect(selection.nodes[1]).toEqual(doc.nodes[1]);
    expect(selection.firstNode).toBe(doc.nodes[1]);
    expect(selection.lastNode).toBe(doc.nodes[1]);
    expect(selection.wrapper).toBe(null);
    expect(selection.editor).toBe(null);
    expect(selection.changed()).not.toBe(true);
  });

  it("Shows the editor", () => {
    selection.detectNodes();
    selection.wrap().showEditor()
    expect(selection.changed()).toBe(false);
    expect(selection.blocked).toBe(true);
    expect(selection.wrapper.classList.contains("collaborative-texts-selection")).toBe(true);
    expect(selection.editor).toBeInstanceOf(Editor);
    expect(selection.editor.container.innerHTML).toContain("<p id=\"ct-node-2\">Some content</p>");
    selection.editor.container.innerHTML = "<p>Another content</p>";
    selection.editor.container.dispatchEvent(new Event("input"));
    expect(selection.changed()).toBe(true);
    expect(selection.editor.saveButton.disabled).toBe(false);
  });

  it("Scrolls into view", () => {
    selection.detectNodes();
    selection.wrap().showEditor();
    selection.editor.editor.scrollIntoView = jest.fn();
    selection.scrollIntoView();
    expect(selection.editor.editor.scrollIntoView).toHaveBeenCalledWith({ behavior: "smooth", block: "nearest" });
  });

  it("saves the changes", () => {
    const spy = jest.spyOn(selection.doc.doc, "dispatchEvent");
    selection.detectNodes();
    selection.wrap().showEditor();
    selection.editor.container.innerHTML = "<p>Another content</p>";
    selection.editor.container.dispatchEvent(new Event("input"));
    selection.editor.saveButton.click();
    expect(spy.mock.calls[0][0].type).toBe("collaborative-texts:suggest");
    expect(spy.mock.calls[0][0].detail.nodes[1]).toEqual(doc.nodes[1]);
    expect(spy.mock.calls[0][0].detail.firstNode).toBe(doc.nodes[1]);
    expect(spy.mock.calls[0][0].detail.lastNode).toBe(doc.nodes[1]);
    expect(spy.mock.calls[0][0].detail.replaceNodes).toEqual(selection.editor.container.childNodes);
    expect(spy.mock.calls[0][0].detail.nodes[1].id).toBe("ct-node-2");
    expect(spy.mock.calls[0][0].detail.nodes[1].textContent).toBe("Some content");
    expect(spy.mock.calls[0][0].detail.replaceNodes[0].textContent).toBe("Another content");

  });
});
