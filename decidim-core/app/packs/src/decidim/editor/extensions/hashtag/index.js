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
      suggestion: {
        ...suggestion,
        char: "#",
        pluginKey: HashtagPluginKey,
        items: async ({ query }) => {
          const data = await searchHashtags(query);
          const sorted = data.sort((tag) => tag.name);
          return sorted.slice(0, 5).map((tag) => tag.name);
        },
        render: createSuggestionRenderer(this)
      }
    };
  },

  addNodeView() {
    return createNodeView(this);
  }
});
