import { selectContent } from "../../helpers";

import contextHelpers from "./context";

export default (ctx) => {
  const { getControl, setContent } = contextHelpers(ctx);

  describe("heading", () => {
    const levels = ["2", "3", "4", "5", "6"];
    let selectValue = (value) => {
      const ctrl = getControl("heading");
      ctrl.value = value;
      ctrl.dispatchEvent(new Event("change"));
    }

    it("changes between the heading levels", async () => {
      await setContent("Hello, world!");
      selectContent(ctx.prosemirror);

      levels.forEach((level) => {
        selectValue(level);

        const tag = `h${level}`;
        expect(ctx.prosemirror.innerHTML).toEqual(`<${tag}>Hello, world!</${tag}>`);
      });
    });

    it("changes from existing heading back to normal text", () => {
      levels.forEach(async (level) => {
        const tag = `h${level}`;
        await setContent(`<${tag}>Hello, world!</${tag}>`);
        selectContent(ctx.prosemirror);

        selectValue("normal");

        expect(ctx.prosemirror.innerHTML).toEqual("<p>Hello, world!</p>");
      });
    });
  });
};
