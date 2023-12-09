import { sleep, selectRange } from "../../helpers";

import contextHelpers from "./context";

export default (ctx) => {
  const { getControl, setContent } = contextHelpers(ctx);

  describe("link", () => {
    it("creates a link for the selected text", async () => {
      await setContent("Hello, world!");

      // Select the word "world" from the original text for the link
      await selectRange(ctx.prosemirror, ctx.prosemirror.querySelector("p").firstChild, { start: 7, end: 12 });

      // Open the link dialog and set the values
      getControl("link").click();

      const dialog = document.body.lastElementChild;
      dialog.querySelector("[data-input='href'] input").value = "https://decidim.org";
      dialog.querySelector("[data-input='target'] select").value = "_blank";

      dialog.querySelector("[data-dialog-actions] button[data-action='save']").click();

      // Wait for the next event loop as this is when the dialog closing is
      // handled
      await sleep(0);

      expect(ctx.prosemirror.innerHTML).toEqual(
        '<p>Hello, <a target="_blank" href="https://decidim.org">world</a>!</p>'
      );
    });
  });
};
