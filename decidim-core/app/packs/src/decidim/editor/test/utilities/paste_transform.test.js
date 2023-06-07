import { transformMsDesktop, transformMsCould } from "../../utilities/paste_transform";

import "../helpers";

const uglifyHtml = (html) => html.replace(/[\r\n]+\s+/g, " ").replace(/>\s+</g, "><").trim();

describe("transformMsDesktop", () => {
  const transform = (html) => {
    return uglifyHtml(transformMsDesktop(html));
  };

  it("transforms flat lists to correct list hierarchy", () => {
    const content = `
      <html>
        <head>
          <style>
          <!--
          @list l0
            {mso-list-id:1209340216;
            mso-list-type:hybrid;
            mso-list-template-ids:-1431263748 536870927 536870937 536870939 536870927 536870937 536870939 536870927 536870937 536870939;}
          @list l0:level1
            {mso-level-tab-stop:none;
            mso-level-number-position:left;
            text-indent:-18.0pt;}
          @list l0:level2
            {mso-level-number-format:alpha-lower;
            mso-level-tab-stop:none;
            mso-level-number-position:left;
            text-indent:-18.0pt;}
          @list l0:level3
            {mso-level-number-format:roman-lower;
            mso-level-tab-stop:none;
            mso-level-number-position:right;
            text-indent:-9.0pt;}
          @list l0:level4
            {mso-level-tab-stop:none;
            mso-level-number-position:left;
            text-indent:-18.0pt;}
          @list l0:level5
            {mso-level-number-format:alpha-lower;
            mso-level-tab-stop:none;
            mso-level-number-position:left;
            text-indent:-18.0pt;}
          @list l0:level6
            {mso-level-number-format:roman-lower;
            mso-level-tab-stop:none;
            mso-level-number-position:right;
            text-indent:-9.0pt;}
          @list l0:level7
            {mso-level-tab-stop:none;
            mso-level-number-position:left;
            text-indent:-18.0pt;}
          @list l0:level8
            {mso-level-number-format:alpha-lower;
            mso-level-tab-stop:none;
            mso-level-number-position:left;
            text-indent:-18.0pt;}
          @list l0:level9
            {mso-level-number-format:roman-lower;
            mso-level-tab-stop:none;
            mso-level-number-position:right;
            text-indent:-9.0pt;}
          -->
          </style>
        </head>
        <body lang=en-FI style='tab-interval:36.0pt;word-wrap:break-word'>
          <p class=MsoListParagraphCxSpFirst style='text-indent:-18.0pt;mso-list:l0 level1 lfo1'><![if !supportLists]><b><span
          lang=EN-US style='mso-bidi-font-family:Calibri;mso-bidi-theme-font:minor-latin;
          mso-ansi-language:EN-US'><span style='mso-list:Ignore'>1.<span
          style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span></span></span></b><![endif]><b><span
          lang=EN-US style='mso-ansi-language:EN-US'>First item<o:p></o:p></span></b></p>

          <p class=MsoListParagraphCxSpMiddle style='margin-left:72.0pt;mso-add-space:
          auto;text-indent:-18.0pt;mso-list:l0 level2 lfo1'><![if !supportLists]><span
          lang=EN-US style='mso-bidi-font-family:Calibri;mso-bidi-theme-font:minor-latin;
          mso-ansi-language:EN-US'><span style='mso-list:Ignore'>a.<span
          style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span></span></span><![endif]><span
          lang=EN-US style='mso-ansi-language:EN-US'>Subitem 1.1<o:p></o:p></span></p>

          <p class=MsoListParagraphCxSpMiddle style='margin-left:72.0pt;mso-add-space:
          auto;text-indent:-18.0pt;mso-list:l0 level2 lfo1'><![if !supportLists]><span
          lang=EN-US style='mso-bidi-font-family:Calibri;mso-bidi-theme-font:minor-latin;
          mso-ansi-language:EN-US'><span style='mso-list:Ignore'>b.<span
          style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span></span></span><![endif]><span
          lang=EN-US style='mso-ansi-language:EN-US'>Subitem 1.2<o:p></o:p></span></p>

          <p class=MsoListParagraphCxSpMiddle style='text-indent:-18.0pt;mso-list:l0 level1 lfo1'><![if !supportLists]><b><span
          lang=EN-US style='mso-bidi-font-family:Calibri;mso-bidi-theme-font:minor-latin;
          mso-ansi-language:EN-US'><span style='mso-list:Ignore'>2.<span
          style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span></span></span></b><![endif]><b><span
          lang=EN-US style='mso-ansi-language:EN-US'>Second item<o:p></o:p></span></b></p>

          <p class=MsoListParagraphCxSpMiddle style='margin-left:72.0pt;mso-add-space:
          auto;text-indent:-18.0pt;mso-list:l0 level2 lfo1'><![if !supportLists]><span
          lang=EN-US style='mso-bidi-font-family:Calibri;mso-bidi-theme-font:minor-latin;
          mso-ansi-language:EN-US'><span style='mso-list:Ignore'>a.<span
          style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span></span></span><![endif]><span
          lang=EN-US style='mso-ansi-language:EN-US'>Subitem 2.1<o:p></o:p></span></p>

          <p class=MsoListParagraphCxSpLast style='margin-left:72.0pt;mso-add-space:auto;
          text-indent:-18.0pt;mso-list:l0 level2 lfo1'><![if !supportLists]><span
          lang=EN-US style='mso-bidi-font-family:Calibri;mso-bidi-theme-font:minor-latin;
          mso-ansi-language:EN-US'><span style='mso-list:Ignore'>b.<span
          style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span></span></span><![endif]><span
          lang=EN-US style='mso-ansi-language:EN-US'>Subitem 2.2<o:p></o:p></span></p>
        </body>
      </html>
    `;

    expect(transform(content)).toMatchHtml(`
      <ol type="1">
        <li>
          <p><b><span lang="EN-US" style="mso-ansi-language:EN-US">First item<o:p></o:p></span></b></p>
          <ol type="a">
            <li><p><span lang="EN-US" style="mso-ansi-language:EN-US">Subitem 1.1<o:p></o:p></span></p></li>
            <li><p><span lang="EN-US" style="mso-ansi-language:EN-US">Subitem 1.2<o:p></o:p></span></p></li>
          </ol>
        </li>
        <li>
          <p><b><span lang="EN-US" style="mso-ansi-language:EN-US">Second item<o:p></o:p></span></b></p>
          <ol type="a">
            <li><p><span lang="EN-US" style="mso-ansi-language:EN-US">Subitem 2.1<o:p></o:p></span></p></li>
            <li><p><span lang="EN-US" style="mso-ansi-language:EN-US">Subitem 2.2<o:p></o:p></span></p></li>
          </ol>
        </li>
      </ol>
    `);
  });

  it("transforms flat lists with a single item to a list", () => {
    const content = `
      <html>
        <head>
          <style>
          <!--
          @list l0
            {mso-list-id:608706399;
            mso-list-type:hybrid;
            mso-list-template-ids:1914210008 536870927 536870937 536870939 536870927 536870937 536870939 536870927 536870937 536870939;}
          @list l0:level1
            {mso-level-number-format:bullet;
            mso-level-text:;
            mso-level-tab-stop:none;
            mso-level-number-position:left;
            text-indent:-18.0pt;
            font-family:Symbol;}
          -->
          </style>
        </head>
        <body lang=en-FI style='tab-interval:36.0pt;word-wrap:break-word'>
          <p class=MsoListParagraph style='text-indent:-18.0pt;mso-list:l0 level1 lfo1'><![if !supportLists]><span
          lang=en-FI style='mso-bidi-font-family:Calibri;mso-bidi-theme-font:minor-latin'><span
          style='mso-list:Ignore'>1.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          </span></span></span><![endif]><span lang=EN-US style='mso-ansi-language:EN-US'>Single
          item list</span><span lang=en-FI><o:p></o:p></span></p>
        </body>
      </html>
    `;
    expect(transform(content)).toMatchHtml(`
      <ul>
        <li>
          <p><span lang="EN-US" style="mso-ansi-language:EN-US">Single item list</span><span lang="en-FI"><o:p></o:p></span></p>
        </li>
      </ul>
    `);
  });
});

describe("transformMsCould", () => {
  const transform = (html) => {
    return uglifyHtml(transformMsCould(html));
  };

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
