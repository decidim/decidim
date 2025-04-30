import Mention from "@tiptap/extension-mention";

import { createSuggestionRenderer, createNodeView } from "src/decidim/editor/common/suggestion";

const searchUsers = async (queryText) => {
  const query = `{
    users(filter: { wildcard: "${queryText}" }) {
      nickname,
      name,
      avatarUrl,
      __typename
    }
  }`;


  return fetch(window.Decidim.config.get("api_path"), {
    method: "POST",
    cache: "no-cache",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ query })
  }).then((response) => {
    if (response.ok) {
      return response.json();
    }
    throw new Error("Could not retrieve data");
  }).then((json) => (json.data.users || []));
};

export default Mention.extend({
  addOptions() {
    const parentOptions = this.parent?.();

    return {
      ...parentOptions,
      renderLabel({ node }) {
        // The labels are formed based on the nicknames returned by the API
        // which already contain the suggestion character, so there is no need
        // to display it twice.
        return `${node.attrs.label ?? node.attrs.id}`
      },
      suggestion: {
        ...parentOptions?.suggestion,
        allowSpaces: true,
        items: async ({ query }) => {
          if (query.length < 2) {
            return [];
          }

          const data = await searchUsers(query);
          const sorted = data.sort((user) => user.nickname.slice(1));
          return sorted.slice(0, 5);
        },
        render: createSuggestionRenderer(this, {
          itemConverter: (user) => {
            return { id: user.nickname, label: `${user.nickname} (${user.name})` }
          }
        })
      }
    };
  },

  addNodeView() {
    return createNodeView(this);
  }
});
