# frozen_string_literal: true

module Decidim
  module Admin
    # This class is used to generate fake newsletters and data to preview
    # newsletter templates.
    class FakeNewsletter
      def initialize(organization, manifest)
        @organization = organization
        @manifest = manifest
      end

      def id
        1
      end

      def template
        @template ||= Decidim::ContentBlock.new(
          in_preview: true,
          manifest_name: manifest.name,
          scope_name: :newsletter_template,
          settings: manifest.settings.attributes.inject({}) do |acc, (name, attrs)|
            value = if attrs.preview.respond_to?(:call)
                      attrs.preview.call
                    else
                      attrs.preview
                    end

            acc.update(name => value)
          end
        )
      end

      def subject
        organization.available_locales.inject({}) do |acc, locale|
          acc.update(locale => "Lorem ipsum")
        end
      end

      def sent_at
        nil
      end

      def draft?
        true
      end

      private

      attr_reader :organization, :manifest
    end
  end
end
