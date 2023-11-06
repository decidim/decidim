import { selectContent } from "../../helpers";

import contextHelpers from "./context";

export default (ctx) => {
  const { getControl, setContent } = contextHelpers(ctx);

  describe("orderedList", () => {
    it("creates a new ordered list", async () => {
      await setContent("Hello, world!");
      ctx.prosemirror.focus();
      getControl("orderedList").click();

      expect(ctx.prosemirror.innerHTML).toEqual("<ol><li><p>Hello, world!</p></li></ol>");
    });

    it("makes existing ordered list as normal text", async () => {
      await setContent("<ol><li><p>Hello, world!</p></li></ol>");
      ctx.prosemirror.focus();

      selectContent(ctx.prosemirror, "ol li p");
      getControl("orderedList").click();

      expect(ctx.prosemirror.innerHTML).toEqual("<p>Hello, world!</p>");
    });
  });

  describe("bulletList", () => {
    it("creates a new bullet list", async () => {
      await setContent("Hello, world!");
      ctx.prosemirror.focus();
      getControl("bulletList").click();

      expect(ctx.prosemirror.innerHTML).toEqual("<ul><li><p>Hello, world!</p></li></ul>");
    });

    it("makes existing bullet list as normal text", async () => {
      await setContent("<ul><li><p>Hello, world!</p></li></ul>");
      ctx.prosemirror.focus();

      selectContent(ctx.prosemirror, "ul li p");
      getControl("bulletList").click();

      expect(ctx.prosemirror.innerHTML).toEqual("<p>Hello, world!</p>");
    });
  });
};
