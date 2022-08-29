# frozen_string_literal: true

module Decidim
  # A context aware presenter for participatory space manifest for translations
  class ParticipatorySpaceManifestPresenter < SimpleDelegator
    attr_reader :organization

    def initialize(manifest, organization)
      super(manifest)

      @organization = organization
    end

    def human_name(count: 1)
      organization.available_locales.index_with do |locale|
        model_class.model_name.human(count:, locale:)
      end
    end

    def model_class
      model_class_name.constantize
    end
  end
end
