# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

Decidim::Webpacker.register_path("#{base_path}/app/packs")
Decidim::Webpacker.register_entrypoints(
  decidim_comments: "#{base_path}/app/packs/entrypoints/decidim_comments.js"
)

common_parameters = { resource: "Decidim::Comments::Comment", category: "actions", engine: :comments }

Decidim.icons.register(name: "thumb-up-line", icon: "thumb-up-line", description: "Upvote comment button", **common_parameters)
Decidim.icons.register(name: "thumb-up-fill", icon: "thumb-up-fill", description: "User upvoted comment", **common_parameters)
Decidim.icons.register(name: "thumb-down-line", icon: "thumb-down-line", description: "Downvote comment button", **common_parameters)
Decidim.icons.register(name: "thumb-down-fill", icon: "thumb-down-fill", description: "User downvoted comment", **common_parameters)
Decidim.icons.register(name: "edit-line", icon: "edit-line", description: "Edit comment button", **common_parameters)
