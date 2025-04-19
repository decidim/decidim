import Mention from "@tiptap/extension-mention";
import { PluginKey } from "prosemirror-state";

import { createSuggestionRenderer, createNodeView } from "src/decidim/editor/common/suggestion";

export const MentionResourcePluginKey = new PluginKey("mentionResource");

const searchResources = async (queryText) => {
  const currentParticipatorySpace = document.querySelector("meta[name='context-current-participatory-space']")?.content;

  let url = `/resource_autocomplete?term=${queryText}`;

  if (currentParticipatorySpace) {
    url += `&participatory_space_gid=${currentParticipatorySpace}`;
  }

  return new Promise((resolve, reject) => {
    Rails.ajax({
      url,
      type: "GET",
      dataType: "json",
      success: (response) => resolve(response),
      error: () => reject(new Error("Could not retrieve data"))
    });
  });
};

export default Mention.extend({
  name: "mentionResource",

  addOptions() {
    const options = this.parent?.();
    const suggestion = options?.suggestion;

    return {
      ...options,
      renderLabel({ node }) {
        // The labels are formed based on the titles returned by the API
        // which already contain the suggestion character, so there is no need
        // to display it twice.
        return `${node.attrs.label ?? node.attrs.id}`
      },
      suggestion: {
        ...suggestion,
        char: "/",
        pluginKey: MentionResourcePluginKey,
        allowSpaces: false,
        items: async ({ query }) => {
          const data = await searchResources(query);

          return data;
        },
        render: createSuggestionRenderer(this, {
          itemConverter: (resource) => {
            return {
              id: resource.gid,
              label: resource.title,
              help: resource.help
            }
          }
        })
      }
    };
  },

  addNodeView() {
    return createNodeView(this);
  }
});
