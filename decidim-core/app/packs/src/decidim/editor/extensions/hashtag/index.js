import Mention from "@tiptap/extension-mention";
import { PluginKey } from "prosemirror-state";

import { createSuggestionRenderer, createNodeView } from "src/decidim/editor/common/suggestion";

export const HashtagPluginKey = new PluginKey("hashtag");

const searchHashtags = async (queryText) => {
  return fetch("/api", {
    method: "POST",
    cache: "no-cache",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ query: `{ hashtags(name:"${queryText}") {name} }` })
  }).then((response) => {
    if (response.ok) {
      return response.json();
    }
    throw new Error("Could not retrieve data");
  }).then((json) => (json.data.hashtags || []));
};

/**
 * The hashtag extension does not yet exist in the TipTap public repository and
 * also the documentation page shows it as
 * https://tiptap.dev/api/nodes/hashtag
 */
export default Mention.extend({
  name: "hashtag",

  addOptions() {
    const options = this.parent?.();
    const suggestion = options?.suggestion;

    return {
      ...options,
      renderLabel({ node }) {
        // The labels already have the suggestion character in front of them
        // which is why we do not want to add it twice.
        return `${node.attrs.label ?? node.attrs.id}`
      },
      suggestion: {
        ...suggestion,
        char: "#",
        pluginKey: HashtagPluginKey,
        items: async ({ query }) => {
          if (query.length < 2) {
            return [];
          }

          const data = await searchHashtags(query);
          const sorted = data.sort((tag) => tag.name);
          return sorted.slice(0, 5);
        },
        render: createSuggestionRenderer(this, {
          itemConverter: (tag) => {
            return { label: `#${tag.name}` }
          }
        })
      }
    };
  },

  addNodeView() {
    return createNodeView(this);
  }
});
