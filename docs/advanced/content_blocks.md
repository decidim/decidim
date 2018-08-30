# Content blocks

Content blocks come from the need of making sortable and configurable layout chunks. The abstraction is similar to view hooks, but content blocks allow the user to manually configure and sort each block. The order and configuration is backed in the database.

As of today, content blocks can be:

- Sorted
- Published

Configuration will come in the near future.

Content blocks are defined per scope, and must be unique in that scope. Examples of scopes could be `:homepage` or `:process_page`.

Content blocks are used in the organization homepage.

## Registering a content block

Content blocks use the same manifests-registry pattern used in other places around Decidim. Here's how to register them:

```ruby
Decidim.content_blocks.register(:homepage, :stats) do |content_block|
  content_block.cell "decidim/content_blocks/stats_block"
  content_block.public_name_key "decidim.content_blocks.stats_block.name"
end
```

Let's analyze the example. In the first line, we register a content block named `:stats` for the `:homepage` scope. Then we define the name of the `cell` that will be used to render the content block, and we define the i18n key that holds the name for the content block. These are the only required fields to register a content block.

Note that content blocks need to be registered from an initializer. If you are adding a content block from a module, use this in the `engine.rb` file of your module:

```ruby
module Decidim::MyModule::Engine < ::Rails::Engine
  # ...

  initializer "decidim.my_module.content_blocks" do
    Decidim.content_blocks.register(:homepage, :my_content_block) do |content_block|
      # ...
    end
  end

  # ...
end
```

## Managing content blocks

Currently content blocks are only used in the homepage. You can manage them in the admin area, under Settings -> Homepage. you need to be an organization admin in order to enter this section.

You'll see all the registered content blocks, those active and those inactive. You can reorder blocks and (un)publish them.

## Rendering content blocks

You can check the code we use in the homepage to render them, or use something like this:

```ruby
<% Decidim::ContentBlock.published.for_scope(:homepage, organization: current_organization).each do |content_block| %>
  <% next unless content_block.manifest %>
  <%= cell content_block.manifest.cell %>
<% end %>
```