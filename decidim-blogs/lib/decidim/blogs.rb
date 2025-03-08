# frozen_string_literal: true

require "decidim/blogs/admin"
require "decidim/blogs/api"
require "decidim/blogs/engine"
require "decidim/blogs/admin_engine"
require "decidim/blogs/component"

module Decidim
  # This namespace holds the logic of the `Blogs` component. This component
  # allows the admins to create a custom blog for a participatory process.
  module Blogs
    autoload :PostSerializer, "decidim/blogs/post_serializer"
    autoload :SchemaOrgBlogPostingPostSerializer, "decidim/blogs/schema_org_blog_posting_post_serializer"
  end
end
