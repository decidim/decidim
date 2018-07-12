# frozen_string_literal: true

module Decidim
  # This class acts as a registry for content blocks.
  #
  # A content block is a view section in a given page. Those sections can be
  # registered by Decidim modules, and are configurable and sortable. They are a
  # useful way to customize a given page, without having to rely on overwriting
  # the views files. Also, this system is more powerful than basic view hooks
  # (see the `ViewHooks` class for reference), as view hooks don't have a way to
  # explicitly control the order of the hooked views.
  #
  # Content blocks are intended to be used in the home page, for example.
  #
  # A content block has a set of options and an associated `cell` that will
  # handle the layout logic. They can also have attached images that can be used
  # as background images, for example. You must explicitly specify the number of
  # images the block will have (this means the number of attached images cannot
  # be configurable). Each content block is identified by a name, which has to
  # be unique per scope.
  #
  # In order to register a content block, you can follow this example:
  #
  #     Decidim.content_blocks.register(:homepage, :global_stats) do |content_block|
  #       content_block.option :minimum_priority_level,
  #                         :integer
  #                         default: lambda { StatsRegistry::HIGH_PRIORITY }
  #                         values: lambda { [StatsRegistry::HIGH_PRIORITY, StatsRegistry::MEDIUM_PRIORITY] }
  #       content_block.cell "decidim/content_blocks/stats_block"
  #     end
  #
  # Content blocks can also register attached images. Here's an example of a
  # content block with 4 attached images:
  #
  #     Decidim.content_blocks.register(:homepage, :carousel) do |content_block|
  #       content_block.image :image_1
  #       content_block.image :image_2
  #       content_block.image :image_3
  #       content_block.image :image_4
  #       content_block.cell "decidim/content_blocks/carousel_block"
  #     end
  class ContentBlockRegistry
    # Public: Registers a content block for the home page.
    #
    # scope - a symbol or string representing the scope of the content block.
    #         Will be persisted as a string.
    # name - a symbol representing the name of the content block
    # &block - The content block definition.
    #
    # Returns nothing. Raises an error if there's already a content block
    # registered with that name.
    def register(scope, name)
      scope = scope.to_s
      block_exists = content_blocks[scope].any? { |content_block| content_block.name == name }

      if block_exists
        raise(
          ContentBlockAlreadyRegistered,
          "There's a content block already registered with the name `:#{name}` for the scope `:#{scope}, must be unique"
        )
      end

      content_block = ContentBlockManifest.new(name: name)

      yield(content_block)

      content_block.validate!
      content_blocks[scope].push(content_block)
    end

    def for(scope)
      content_blocks[scope.to_s]
    end

    def all
      content_blocks
    end

    class ContentBlockAlreadyRegistered < StandardError; end

    private

    def content_blocks
      @content_blocks ||= Hash.new { |h, k| h[k] = [] }
    end
  end
end
