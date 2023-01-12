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

  describe("bold", () => {
    it("makes text bold", async () => {
      await setContent("Hello, world!");
      selectContent(ctx.prosemirror);
      getControl("bold").click();

      expect(ctx.prosemirror.innerHTML).toEqual("<p><strong>Hello, world!</strong></p>");
    });

    it("makes already bolded text normal", async () => {
      await setContent("<p>Hello, <strong>world!</strong></p>");

      selectContent(ctx.prosemirror, "p strong");
      getControl("bold").click();

      expect(ctx.prosemirror.innerHTML).toEqual("<p>Hello, world!</p>");
    });
  });

  describe("italic", () => {
    it("makes text italic", async () => {
      await setContent("Hello, world!");
      selectContent(ctx.prosemirror);
      getControl("italic").click();

      expect(ctx.prosemirror.innerHTML).toEqual("<p><em>Hello, world!</em></p>");
    });

    it("makes already italic text normal", async () => {
      await setContent("<p>Hello, <em>world!</em></p>");

      selectContent(ctx.prosemirror, "p em");
      getControl("italic").click();

      expect(ctx.prosemirror.innerHTML).toEqual("<p>Hello, world!</p>");
    });
  });

  describe("underline", () => {
    it("makes text underlined", async () => {
      await setContent("Hello, world!");
      selectContent(ctx.prosemirror);
      getControl("underline").click();

      expect(ctx.prosemirror.innerHTML).toEqual("<p><u>Hello, world!</u></p>");
    });

    it("makes already underlined text normal", async () => {
      await setContent("<p>Hello, <u>world!</u></p>");

      selectContent(ctx.prosemirror, "p u");
      getControl("underline").click();

      expect(ctx.prosemirror.innerHTML).toEqual("<p>Hello, world!</p>");
    });
  });

  describe("common:eraseStyles", () => {
    it("erases all existing marks and sub-nodes from the element", async () => {
      await setContent(
        '<p>Hello, <a target="_blank" rel="noopener noreferrer nofollow" href="https://decidim.org"><strong><em><u>world</u><em></strong></a>!</p>'
      );
      selectContent(ctx.prosemirror);

      getControl("common:eraseStyles").click();

      expect(ctx.prosemirror.innerHTML).toEqual("<p>Hello, world!</p>")
    });

    it("makes ordered list content as normal text", async () => {
      await setContent("<ol><li><p>Hello, world!</p></li></ol>");
      selectContent(ctx.prosemirror);

      getControl("common:eraseStyles").click();

      expect(ctx.prosemirror.innerHTML).toEqual("<p>Hello, world!</p>")
    });

    it("makes bullet list content as normal text", async () => {
      await setContent("<ul><li><p>Hello, world!</p></li></ul>");
      selectContent(ctx.prosemirror);

      getControl("common:eraseStyles").click();

      expect(ctx.prosemirror.innerHTML).toEqual("<p>Hello, world!</p>")
    });
  });
};
