# frozen_string_literal: true

module Decidim
  # This class acts as a manifest for content blocks.
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
  class ContentBlockManifest
    include ActiveModel::Model
    include Virtus.model

    attribute :name, Symbol
    attribute :cell_name, String, writer: :private
    attribute :image_names, Array[Symbol]
    attribute :options, Array[Hash]

    validates :name, :cell_name, presence: true
    validate :image_names_are_unique
    validate :option_names_are_unique

    # Public: Registers an image with a given name. Use `#images` to retrieve
    # them all.
    def image(name)
      raise ImageNameCannotBeBlank if name.blank?

      image_names << name
    end

    # Public: Registers the cell this content block will use to render itself.
    # Use `#cell_name` to retrieve it.
    def cell(cell_name)
      self.cell_name = cell_name
    end

    # Public: Registers an option. Use `#options` to retrieve them all.
    def option(name, type, metadata = {})
      raise OptionNameCannotBeBlank, "Option names cannot be blank" if name.blank?
      raise OptionTypeCannotBeBlank, "Option types cannot be blank" if type.blank?

      options << { name: name, type: type }.merge(metadata)
    end

    private

    def option_names_are_unique
      option_names = options.map { |option| option.fetch(:name) }
      errors.add(:options, :invalid) if option_names.count != option_names.uniq.count
    end

    def image_names_are_unique
      errors.add(:image_names, :invalid) if image_names.count != image_names.uniq.count
    end

    class ImageNameCannotBeBlank < StandardError; end
    class OptionNameCannotBeBlank < StandardError; end
    class OptionTypeCannotBeBlank < StandardError; end
  end
end
