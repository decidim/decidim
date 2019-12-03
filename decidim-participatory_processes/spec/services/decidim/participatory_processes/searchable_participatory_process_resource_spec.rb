# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Search do
    it_behaves_like "global search of participatory spaces" do
      let(:participatory_process) do
        create(
          :participatory_process,
          :unpublished,
          organization: organization,
          scope: scope1,
          title: Decidim::Faker::Localized.name,
          subtitle: Decidim::Faker::Localized.name,
          short_description: Decidim::Faker::Localized.sentence,
          description: description_1,
          users: [author]
        )
      end
      let(:participatory_space) { participatory_process }
      let(:participatory_process_2) do
        create(
          :participatory_process,
          organization: organization,
          scope: scope1,
          title: Decidim::Faker::Localized.name,
          subtitle: Decidim::Faker::Localized.name,
          short_description: Decidim::Faker::Localized.sentence,
          description: description_2,
          users: [author]
        )
      end
      let(:participatory_space2) { participatory_process_2 }
      let(:searchable_resource_attrs_mapper) do
        lambda { |space, locale|
          {
            "content_a" => I18n.transliterate(space.title[locale]),
            "content_b" => I18n.transliterate(space.subtitle[locale]),
            "content_c" => I18n.transliterate(space.short_description[locale]),
            "content_d" => I18n.transliterate(space.description[locale])
          }
        }
      end
    end
  end
end
