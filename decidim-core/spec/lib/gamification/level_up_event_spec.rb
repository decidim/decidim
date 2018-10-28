# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Gamification
    describe LevelUpEvent do
      include_context "when a simple event"

      let(:extra) { { badge_name: "test", previous_level: 2, current_level: 3 } }
      let(:event_name) { "decidim.events.gamification.level_up" }
      let(:resource) { create(:user) }
      let(:resource_path) do
        Decidim::Core::Engine.routes.url_helpers.profile_badges_path(nickname: resource.nickname)
      end

      it_behaves_like "a simple event", skip_space_checks: true

      describe "email_subject" do
        it "is generated correctly" do
          expect(subject.email_subject).to include("level 3")
        end
      end

      describe "email_intro" do
        it "is generated correctly" do
          expect(subject.email_intro).to include(resource_path)
        end
      end
    end
  end
end
