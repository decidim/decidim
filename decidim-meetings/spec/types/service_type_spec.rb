# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Meetings
    describe ServiceType, type: :graphql do
      include_context "with a graphql class type"
      let(:model) do
        double(
          title: title,
          description: description
        )
      end
      let(:title) { Decidim::Faker::Localized.name }
      let(:description) { Decidim::Faker::Localized.sentence(word_count: 3) }

      describe "title" do
        let(:query) { '{ title { translation(locale: "en") } }' }

        it "returns the service's title" do
          expect(response["title"]["translation"]).to eq(title[:en])
        end
      end

      describe "description" do
        let(:query) { '{ description { translation(locale: "en") } }' }

        it "returns the service's description" do
          expect(response["description"]["translation"]).to eq(description[:en])
        end
      end
    end
  end
end
