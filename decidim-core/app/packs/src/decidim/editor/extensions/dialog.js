import { Extension } from "@tiptap/core";
import { Plugin, PluginKey } from "prosemirror-state";

export default Extension.create({
  name: "dialog",

  addStorage() {
    return { open: false };
  },

  addCommands() {
    return {
      toggleDialog: (open) => () => (this.storage.open = open)
    };
  },

  addProseMirrorPlugins() {
    return [
      new Plugin({
        key: new PluginKey("editable"),
        props: {
          modalOpen: () => this.storage.open,
          attributes: () => {
            if (this.storage.open) {
              return { class: "dialog-open" };
            }

            return {};
          }
        }
      })
    ]
  }
});
