import { selectContent, selectRange } from "../../helpers";

import contextHelpers from "./context";

export default (ctx) => {
  const { getControl, setContent } = contextHelpers(ctx);

  describe("indent:indent", () => {
    it("indents the existing content", async () => {
      await setContent("Hello, world!");
      await selectRange(ctx.prosemirror, ctx.prosemirror.querySelector("p").firstChild, { start: 3, end: 3 });
      const ctrl = getControl("indent:indent");
      ctrl.click();
      ctrl.click();

      expect(ctx.prosemirror.innerHTML).toEqual('<p class="editor-indent-2">Hello, world!</p>');
    });

    it("indents a list item correctly", async () => {
      await setContent("<ul><li><p>First item</p></li><li><p>Second item</p></li></ul>");
      selectContent(ctx.prosemirror, "ul li:nth-child(2) p");
      getControl("indent:indent").click();

      expect(ctx.prosemirror.innerHTML).toEqual(
        "<ul><li><p>First item</p><ul><li><p>Second item</p></li></ul></li></ul>"
      );
    });
  });

  describe("indent:outdent", () => {
    it("outdents the existing content", async () => {
      await setContent('<p class="editor-indent-2">Hello, world!</p>');
      await selectRange(ctx.prosemirror, ctx.prosemirror.querySelector("p").firstChild, { start: 3, end: 3 });
      const ctrl = getControl("indent:outdent");
      ctrl.click();
      ctrl.click();

      expect(ctx.prosemirror.innerHTML).toEqual("<p>Hello, world!</p>");
    });

    it("outdents a list item correctly", async () => {
      await setContent("<ul><li><p>First item</p><ul><li><p>Second item</p></li></ul></li></ul>");
      selectContent(ctx.prosemirror, "ul li ul li p");
      getControl("indent:outdent").click();

      expect(ctx.prosemirror.innerHTML).toEqual(
        "<ul><li><p>First item</p></li><li><p>Second item</p></li></ul>"
      );
    });

    it("does nothing on a top-level list item", async () => {
      await setContent("<ul><li><p>First item</p></li><li><p>Second item</p></li></ul>");
      selectContent(ctx.prosemirror, "ul li:nth-child(2) p");
      getControl("indent:outdent").click();

      expect(ctx.prosemirror.innerHTML).toEqual(
        "<ul><li><p>First item</p></li><li><p>Second item</p></li></ul>"
      );
    });
  });
};
