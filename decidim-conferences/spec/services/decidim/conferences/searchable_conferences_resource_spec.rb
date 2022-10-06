# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Search do
    it_behaves_like "global search of participatory spaces" do
      let(:conference) do
        create(
          :conference,
          :unpublished,
          organization:,
          scope: scope1,
          title: Decidim::Faker::Localized.name,
          short_description: Decidim::Faker::Localized.sentence,
          objectives: Decidim::Faker::Localized.sentence,
          description: description1
        )
      end
      let(:participatory_space) { conference }
      let(:conference2) do
        create(
          :conference,
          organization:,
          scope: scope1,
          title: Decidim::Faker::Localized.name,
          short_description: Decidim::Faker::Localized.sentence,
          objectives: Decidim::Faker::Localized.sentence,
          description: description2
        )
      end
      let(:participatory_space2) { conference2 }
      let(:searchable_resource_attrs_mapper) do
        lambda { |space, locale|
          d = I18n.transliterate(translated(space.description, locale:))
          d += " "
          d += I18n.transliterate(translated(space.objectives, locale:))
          {
            "content_a" => I18n.transliterate(translated(space.title, locale:)),
            "content_b" => I18n.transliterate(translated(space.slogan, locale:)),
            "content_c" => I18n.transliterate(translated(space.short_description, locale:)),
            "content_d" => d
          }
        }
      end
    end
  end
end
