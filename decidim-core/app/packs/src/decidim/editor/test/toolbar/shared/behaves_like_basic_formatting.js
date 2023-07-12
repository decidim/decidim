import contextHelpers from "./context";

export default (ctx) => {
  const { getControl, setContent } = contextHelpers(ctx);

  describe("hardBreak", () => {
    it("creates a new line break at the cursor position", async () => {
      await setContent("Hello, world!");
      ctx.prosemirror.focus();
      getControl("hardBreak").click();

      // Note that the "tailingBreak" is only ProseMirror's internal element
      // to place the cursor at the correct location.
      expect(ctx.prosemirror.innerHTML).toEqual('<p>Hello, world!<br><br class="ProseMirror-trailingBreak"></p>');
    });
  });
};
