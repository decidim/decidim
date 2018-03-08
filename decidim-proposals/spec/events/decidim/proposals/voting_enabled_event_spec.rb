# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe VotingEnabledEvent do
      include Decidim::FeaturePathHelper

      include_context "simple event"

      let(:event_name) { "decidim.events.proposals.voting_enabled" }
      let(:resource) { create(:proposal_feature) }
      let(:participatory_space) { resource.participatory_space }
      let(:resource_path) { main_feature_path(resource) }

      it_behaves_like "a simple event"

      describe "email_subject" do
        it "is generated correctly" do
          expect(subject.email_subject).to eq("Proposals voting has started for #{participatory_space.title["en"]}")
        end
      end

      describe "email_intro" do
        it "is generated correctly" do
          expect(subject.email_intro)
            .to eq("You can vote proposals in #{participatory_space_title}! Start participating in this page:")
        end
      end

      describe "email_outro" do
        it "is generated correctly" do
          expect(subject.email_outro)
            .to include("You have received this notification because you are following #{participatory_space.title["en"]}")
        end
      end

      describe "notification_title" do
        it "is generated correctly" do
          expect(subject.notification_title)
            .to eq("You can now start <a href=\"#{resource_path}\">voting proposals</a> in <a href=\"#{participatory_space_url}\">#{participatory_space.title["en"]}</a>")
        end
      end
    end
  end
end
