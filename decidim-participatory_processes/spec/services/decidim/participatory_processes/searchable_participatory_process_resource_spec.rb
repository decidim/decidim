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
          subtitle: subtitle_1,
          short_description: Decidim::Faker::Localized.sentence,
          description: Decidim::Faker::Localized.paragraph,
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
    end
  end
end
