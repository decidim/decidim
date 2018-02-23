# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe CreateProposalEvent do
      let(:resource) { create :proposal }
      let(:event_name) { "decidim.events.proposals.proposal_created" }

      include_context "simple event"
      it_behaves_like "a simple event"

      describe "email_subject" do
        it "is generated correctly" do
          expect(subject.email_subject).to eq("New proposal by @#{author.nickname}")
        end
      end

      describe "email_intro" do
        it "is generated correctly" do
          expect(subject.email_intro)
            .to eq("#{author.name} @#{author.nickname}, who you are following, has created a new proposal, check it out and contribute:")
        end
      end

      describe "email_outro" do
        it "is generated correctly" do
          expect(subject.email_outro)
            .to eq("You have received this notification because you are following @#{author.nickname}. You can stop receiving notifications following the previous link.")
        end
      end

      describe "notification_title" do
        it "is generated correctly" do
          expect(subject.notification_title)
            .to include("The <a href=\"#{resource_path}\">#{resource.title}</a> proposal was created by ")

          expect(subject.notification_title)
            .to include("<a href=\"/profiles/#{author.nickname}\">#{author.name} @#{author.nickname}</a>.")
        end
      end
    end
  end
end
