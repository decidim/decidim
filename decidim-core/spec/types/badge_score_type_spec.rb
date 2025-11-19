# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Core
    describe BadgeScoreType do
      include_context "with a graphql class type"

      let(:model) { create(:badge_score) }
      let(:status) { Decidim::Gamification.status_for(model.user, model.badge_name) }

      describe "description" do
        let(:query) { "{ description }" }

        it "returns the badge's description" do
          expect(response["description"]).to eq(translated(status.badge.description))
        end
      end

      describe "image" do
        let(:query) { "{ image }" }

        it "returns the badge's image" do
          expect(response["image"]).to eq(status.badge.image)
        end
      end

      describe "level" do
        let(:query) { "{ level }" }

        it "returns the badge's level" do
          expect(response["level"]).to eq(status.level)
        end
      end

      describe "name" do
        let(:query) { "{ name }" }

        it "returns the badge's name" do
          expect(response["name"]).to eq(model.badge_name)
        end
      end

      describe "score" do
        let(:query) { "{ score }" }

        it "returns the badge's score" do
          expect(response["score"]).to eq(status.score)
        end
      end
    end
  end
end
