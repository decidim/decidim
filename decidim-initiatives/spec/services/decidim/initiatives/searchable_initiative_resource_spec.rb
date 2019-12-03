# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Search do
    it_behaves_like "global search of participatory spaces" do
      let(:initiative) do
        create(
          :initiative,
          :unpublished,
          organization: organization,
          title: Decidim::Faker::Localized.name,
          description: description_1
        )
      end
      let(:participatory_space) { initiative }
      let(:initiative_2) do
        create(
          :initiative,
          organization: organization,
          title: Decidim::Faker::Localized.name,
          description: description_2
        )
      end
      let(:participatory_space2) { initiative_2 }
      let(:searchable_resource_attrs_mapper) do
        lambda { |space, locale|
          {
            "content_a" => I18n.transliterate(space.title[locale]),
            "content_b" => "",
            "content_c" => "",
            "content_d" => I18n.transliterate(space.description[locale])
          }
        }
      end
    end
  end
end
