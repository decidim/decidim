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
  # A content block has a set of settings and an associated `cell` that will
  # handle the layout logic. They can also have attached images that can be used
  # as background images, for example. You must explicitly specify the number of
  # images the block will have (this means the number of attached images cannot
  # be configurable). Each content block is identified by a name, which has to
  # be unique per scope.
  class ContentBlockManifest
    include ActiveModel::Model
    include Virtus.model

    attribute :name, Symbol
    attribute :i18n_name_key, String
    attribute :cell_name, String, writer: :private
    attribute :image_names, Array[Symbol]

    validates :name, :cell_name, :i18n_name_key, presence: true
    validate :image_names_are_unique

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

    # Public: Registers the I18n key this contnt block will use to retrieve its
    # public name. Use `#i18n_name_key` to retrieve it.
    def public_name_key(i18n_key)
      self.i18n_name_key = i18n_key
    end

    def has_settings?
      settings.attributes.any?
    end

    def settings(&block)
      @settings ||= SettingsManifest.new
      yield(@settings) if block
      @settings
    end

    private

    def image_names_are_unique
      errors.add(:image_names, :invalid) if image_names.count != image_names.uniq.count
    end

    class ImageNameCannotBeBlank < StandardError; end
  end
end
