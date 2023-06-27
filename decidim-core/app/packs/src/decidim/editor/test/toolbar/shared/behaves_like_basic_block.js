import { selectContent } from "../../helpers";

import contextHelpers from "./context";

export default (ctx) => {
  const { getControl, setContent } = contextHelpers(ctx);

  describe("codeBlock", () => {
    it("creates a new code block", async () => {
      await setContent("Hello, world!");
      selectContent(ctx.prosemirror);
      getControl("codeBlock").click();

      expect(ctx.prosemirror.innerHTML).toEqual("<pre><code>Hello, world!</code></pre>");
    });

    it("makes existing code block content as normal text", async () => {
      await setContent("<pre><code>Hello, world!</code></pre>");

      selectContent(ctx.prosemirror, "pre code");
      getControl("codeBlock").click();

      expect(ctx.prosemirror.innerHTML).toEqual("<p>Hello, world!</p>");
    });
  });

  describe("blockquote", () => {
    it("creates a new blockquote", async () => {
      await setContent("Hello, world!");
      selectContent(ctx.prosemirror);
      getControl("blockquote").click();

      expect(ctx.prosemirror.innerHTML).toEqual("<blockquote><p>Hello, world!</p></blockquote>");
    });

    it("makes existing blockquote content as normal text", async () => {
      await setContent("<blockquote><p>Hello, world!</p></blockquote>");

      selectContent(ctx.prosemirror, "blockquote p");
      getControl("blockquote").click();

      expect(ctx.prosemirror.innerHTML).toEqual("<p>Hello, world!</p>");
    });
  });
};
