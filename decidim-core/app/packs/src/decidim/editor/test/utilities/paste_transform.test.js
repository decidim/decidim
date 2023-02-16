import { transformMsCould } from "../../utilities/paste_transform";

import "../helpers";

const uglifyHtml = (html) => html.replace(/[\r\n]+\s+/g, "");

describe("transformMsCould", () => {
  const transform = (html) => {
    return uglifyHtml(transformMsCould(html));
  }

  it("corrects the list hierarchy", () => {
    const content = `
      <div class="ListContainerWrapper">
        <ol style="list-style-type:decimal;">
          <li data-listid="1" data-aria-level="1"><p><span>Item 1</span></p></li>
        </ol>
      </div>
      <div class="ListContainerWrapper">
        <ol style="list-style-type:lower-alpha;">
          <li data-listid="1" data-aria-level="2"><p><span style="font-weight:400;">Subitem 1.1</span></p></li>
        </ol>
      </div>
      <div class="ListContainerWrapper">
        <ol style="list-style-type:lower-alpha;">
          <li data-listid="1" data-aria-level="2"><p><span style="font-weight:normal;">Subitem 1.2</span></p></li>
        </ol>
      </div>
      <div class="ListContainerWrapper">
        <ol style="list-style-type:decimal;">
          <li data-listid="1" data-aria-level="1"><p><span>Item 2</span></p></li>
        </ol>
      </div>
      <div class="ListContainerWrapper">
        <ol style="list-style-type:upper-alpha;">
          <li data-listid="1" data-aria-level="2"><p><span style="font-weight:400;">Subitem 2.1</span></p></li>
        </ol>
      </div>
    `;

    expect(transform(content)).toMatchHtml(`
      <ol style="list-style-type:decimal;">
        <li data-listid="1" data-aria-level="1">
          <p><span>Item 1</span></p>
          <ol style="list-style-type:lower-alpha;">
            <li data-listid="1" data-aria-level="2"><p><span style="font-weight:400;">Subitem 1.1</span></p></li>
            <li data-listid="1" data-aria-level="2"><p><span style="font-weight:normal;">Subitem 1.2</span></p></li>
          </ol>
        </li>
        <li data-listid="1" data-aria-level="1">
          <p><span>Item 2</span></p>
          <ol style="list-style-type:upper-alpha;">
            <li data-listid="1" data-aria-level="2"><p><span style="font-weight:400;">Subitem 2.1</span></p></li>
          </ol>
        </li>
      </ol>
    `);
  });

  // Checks that in case the list level "jumps" over one level, it is handled
  // correctly.
  it("corrects the missing list levels", () => {
    const content = `
      <div class="ListContainerWrapper">
        <ol style="list-style-type:decimal;">
          <li data-listid="1" data-aria-level="1"><p><span>Item 1</span></p></li>
        </ol>
      </div>
      <div class="ListContainerWrapper">
        <ol style="list-style-type:lower-alpha;">
          <li data-listid="1" data-aria-level="3"><p><span style="font-weight:400;">Subitem 1.1</span></p></li>
        </ol>
      </div>
      <div class="ListContainerWrapper">
        <ol style="list-style-type:lower-alpha;">
          <li data-listid="1" data-aria-level="3"><p><span style="font-weight:normal;">Subitem 1.2</span></p></li>
        </ol>
      </div>
      <div class="ListContainerWrapper">
        <ol style="list-style-type:decimal;">
          <li data-listid="1" data-aria-level="1"><p><span>Item 2</span></p></li>
        </ol>
      </div>
      <div class="ListContainerWrapper">
        <ol style="list-style-type:upper-alpha;">
          <li data-listid="1" data-aria-level="2"><p><span style="font-weight:400;">Subitem 2.1</span></p></li>
        </ol>
      </div>
    `;

    expect(transform(content)).toMatchHtml(`
      <ol style="list-style-type:decimal;">
        <li data-listid="1" data-aria-level="1">
          <p><span>Item 1</span></p>
          <ol style="list-style-type:lower-alpha;">
            <li data-listid="1" data-aria-level="3"><p><span style="font-weight:400;">Subitem 1.1</span></p></li>
            <li data-listid="1" data-aria-level="3"><p><span style="font-weight:normal;">Subitem 1.2</span></p></li>
          </ol>
        </li>
        <li data-listid="1" data-aria-level="1">
          <p><span>Item 2</span></p>
          <ol style="list-style-type:upper-alpha;">
            <li data-listid="1" data-aria-level="2"><p><span style="font-weight:400;">Subitem 2.1</span></p></li>
          </ol>
        </li>
      </ol>
    `);
  });
});
