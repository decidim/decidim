import itBehavesLikeBasicToolbarStyling from "src/decidim/editor/test/toolbar/shared/behaves_like_basic_styling";
import itBehavesLikeBasicToolbarFormatting from "src/decidim/editor/test/toolbar/shared/behaves_like_basic_formatting";
import itBehavesLikeBasicToolbarList from "src/decidim/editor/test/toolbar/shared/behaves_like_basic_list";
import itBehavesLikeBasicToolbarBlock from "src/decidim/editor/test/toolbar/shared/behaves_like_basic_block";
import itBehavesLikeBasicToolbarLink from "src/decidim/editor/test/toolbar/shared/behaves_like_basic_link";
import itBehavesLikeBasicToolbarIndent from "src/decidim/editor/test/toolbar/shared/behaves_like_basic_indent";

export default (ctx) => {
  ctx.prosemirror = null;

  describe("basic toolbar controls", () => {
    beforeEach(() => {
      ctx.prosemirror = ctx.editorContainer.querySelector(".editor-input .ProseMirror");
    });

    itBehavesLikeBasicToolbarStyling(ctx);
    itBehavesLikeBasicToolbarFormatting(ctx);
    itBehavesLikeBasicToolbarList(ctx);
    itBehavesLikeBasicToolbarBlock(ctx);
    itBehavesLikeBasicToolbarLink(ctx);
    itBehavesLikeBasicToolbarIndent(ctx);
  });
};
