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
      renderText({ node }) {
        // renderText is used to create the DOM representation
        const label = node.attrs.label ?? node.attrs.id;
        return label;
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

  renderHTML({ node }) {
    // renderHTML is used for visual rendering getHTML()
    const label = node.attrs.label ?? node.attrs.id;
    return [
      "span",
      {
        "data-type": "mention",
        "data-id": node.attrs.id,
        "data-label": node.attrs.label
      },
      label
    ];
  },

  addNodeView() {
    return createNodeView(this);
  }
});
