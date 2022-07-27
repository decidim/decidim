# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Search do
    it_behaves_like "global search of participatory spaces" do
      let(:assembly) do
        create(
          :assembly,
          :unpublished,
          organization:,
          scope: scope1,
          title: Decidim::Faker::Localized.name,
          subtitle: Decidim::Faker::Localized.name,
          short_description: Decidim::Faker::Localized.sentence,
          description: description1,
          users: [author]
        )
      end
      let(:participatory_space) { assembly }
      let(:assembly2) do
        create(
          :assembly,
          organization:,
          scope: scope1,
          title: Decidim::Faker::Localized.name,
          subtitle: Decidim::Faker::Localized.name,
          short_description: Decidim::Faker::Localized.sentence,
          description: description2,
          users: [author]
        )
      end
      let(:participatory_space2) { assembly2 }
      let(:searchable_resource_attrs_mapper) do
        lambda { |space, locale|
          {
            "content_a" => I18n.transliterate(translated(space.title, locale:)),
            "content_b" => I18n.transliterate(translated(space.subtitle, locale:)),
            "content_c" => I18n.transliterate(translated(space.short_description, locale:)),
            "content_d" => I18n.transliterate(translated(space.description, locale:))
          }
        }
      end
    end
  end
end
