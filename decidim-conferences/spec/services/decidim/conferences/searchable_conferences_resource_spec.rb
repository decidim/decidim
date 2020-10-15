# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Search do
    it_behaves_like "global search of participatory spaces" do
      let(:conference) do
        create(
          :conference,
          :unpublished,
          organization: organization,
          scope: scope1,
          title: Decidim::Faker::Localized.name,
          short_description: Decidim::Faker::Localized.sentence,
          objectives: Decidim::Faker::Localized.sentence,
          description: description_1
        )
      end
      let(:participatory_space) { conference }
      let(:conference_2) do
        create(
          :conference,
          organization: organization,
          scope: scope1,
          title: Decidim::Faker::Localized.name,
          short_description: Decidim::Faker::Localized.sentence,
          objectives: Decidim::Faker::Localized.sentence,
          description: description_2
        )
      end
      let(:participatory_space2) { conference_2 }
      let(:searchable_resource_attrs_mapper) do
        lambda { |space, locale|
          d = I18n.transliterate(space.description[locale])
          d += " "
          d += I18n.transliterate(space.objectives[locale])
          {
            "content_a" => I18n.transliterate(space.title[locale]),
            "content_b" => I18n.transliterate(space.slogan[locale]),
            "content_c" => I18n.transliterate(space.short_description[locale]),
            "content_d" => d
          }
        }
      end
    end
  end
end
