# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe CoauthorInvitedEvent do
      let(:resource) { create(:proposal) }
      let(:participatory_process) { create(:participatory_process, organization:) }
      let(:proposal_component) { create(:proposal_component, participatory_space: participatory_process) }
      let(:resource_title) { decidim_sanitize_translated(resource.title) }
      let(:event_name) { "decidim.events.proposals.coauthor_invited" }

      include_context "when a simple event"

      it_behaves_like "a simple event"

      describe "email_subject" do
        context "when resource title contains apostrophes" do
          let(:resource) { create(:proposal) }

          it "is generated correctly" do
            expect(subject.email_subject).to eq("You have been invited to be a co-author of the proposal \"#{resource_title}\"")
          end
        end

        it "is generated correctly" do
          expect(subject.email_subject).to eq("You have been invited to be a co-author of the proposal \"#{resource_title}\"")
        end
      end

      describe "email_intro" do
        it "is generated correctly" do
          expect(subject.email_intro)
            .to eq("You have been invited to be a co-author of the proposal \"#{resource_title}\". You can accept or decline the invitation in this page:")
        end
      end

      describe "email_outro" do
        it "is generated correctly" do
          expect(subject.email_outro)
            .to eq("You have received this notification because the author of the proposal wants to recognize your contributions by becoming a co-author.")
        end
      end

      describe "notification_title" do
        it "is generated correctly" do
          expect(subject.notification_title)
            .to eq("<a href=\"/profiles/#{author.nickname}\">#{author.name}</a> would like to invite you as a co-author of the proposal <a href=\"#{resource_path}\">#{resource_title}</a>.")
        end
      end
    end
  end
end
