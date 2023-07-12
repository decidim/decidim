import itBehavesLikeBasicToolbarStyling from "./behaves_like_basic_styling";
import itBehavesLikeContentToolbarStyling from "./behaves_like_content_styling";
import itBehavesLikeBasicToolbarFormatting from "./behaves_like_basic_formatting";
import itBehavesLikeBasicToolbarList from "./behaves_like_basic_list";
import itBehavesLikeBasicToolbarBlock from "./behaves_like_basic_block";
import itBehavesLikeBasicToolbarLink from "./behaves_like_basic_link";
import itBehavesLikeBasicToolbarIndent from "./behaves_like_basic_indent";

export default (ctx) => {
  ctx.prosemirror = null;

  describe("content toolbar controls", () => {
    beforeEach(() => {
      ctx.prosemirror = ctx.editorContainer.querySelector(".editor-input .ProseMirror");
    });

    itBehavesLikeBasicToolbarStyling(ctx);
    itBehavesLikeBasicToolbarFormatting(ctx);
    itBehavesLikeContentToolbarStyling(ctx);
    itBehavesLikeBasicToolbarList(ctx);
    itBehavesLikeBasicToolbarBlock(ctx);
    itBehavesLikeBasicToolbarLink(ctx);
    itBehavesLikeBasicToolbarIndent(ctx);
  });
};
