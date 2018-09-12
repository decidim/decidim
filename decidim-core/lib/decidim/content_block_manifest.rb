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
    attribute :public_name_key, String
    attribute :cell, String
    attribute :settings_form_cell, String
    attribute :images, Array[Hash]
    attribute :default, Boolean, default: false

    validates :name, :cell, :public_name_key, presence: true
    validates :settings_form_cell, presence: true, if: :has_settings?
    validate :image_names_are_unique
    validate :images_have_an_uploader

    # Public: Registers whether this content block should be shown by default
    # when creating an organization. Use `#default` to retrieve it.
    def default!
      self.default = true
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
      image_names = images.map { |image| image[:name] }
      errors.add(:images, "names must be unique per manifest") if image_names.count != image_names.uniq.count
    end

    def images_have_an_uploader
      uploaders = images.map { |image| image[:uploader].presence }
      errors.add(:images, "must have an uploader") if uploaders.compact.count != images.count
    end
  end
end
