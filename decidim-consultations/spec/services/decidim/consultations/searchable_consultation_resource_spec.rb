# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Search do
    it_behaves_like "global search of participatory spaces" do
      let(:consultation) do
        create(
          :consultation,
          :unpublished,
          organization: organization,
          title: Decidim::Faker::Localized.name,
          subtitle: Decidim::Faker::Localized.name,
          description: description_1
        )
      end
      let(:participatory_space) { consultation }
      let(:consultation_2) do
        create(
          :consultation,
          organization: organization,
          title: Decidim::Faker::Localized.name,
          subtitle: Decidim::Faker::Localized.name,
          description: description_2
        )
      end
      let(:participatory_space2) { consultation_2 }
      let(:searchable_resource_attrs_mapper) do
        lambda { |space, locale|
          {
            "content_a" => I18n.transliterate(translated(space.title, locale: locale)),
            "content_b" => I18n.transliterate(translated(space.subtitle, locale: locale)),
            "content_c" => "",
            "content_d" => I18n.transliterate(translated(space.description, locale: locale))
          }
        }
      end
    end
  end
end
