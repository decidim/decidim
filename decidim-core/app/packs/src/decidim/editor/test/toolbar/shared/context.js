import { updateContent } from "../../helpers";

export default (ctx) => {
  return {
    getControl(type) {
      let selector = "button";
      if (type === "heading") {
        selector = "select";
      }

      return ctx.editorContainer.querySelector(`.editor-toolbar ${selector}[data-editor-type='${type}']`);
    },

    async setContent(editorContent) {
      await updateContent(ctx.prosemirror, editorContent);
    }
  };
};
