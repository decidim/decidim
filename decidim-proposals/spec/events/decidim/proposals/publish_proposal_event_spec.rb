# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe PublishProposalEvent do
      let(:resource) { create :proposal, title: "A nice proposal" }
      let(:participatory_process) { create :participatory_process, organization: }
      let(:proposal_component) { create(:proposal_component, participatory_space: participatory_process) }
      let(:resource_title) { translated(resource.title) }
      let(:event_name) { "decidim.events.proposals.proposal_published" }

      include_context "when a simple event"

      it_behaves_like "a simple event"

      describe "resource_text" do
        it "returns the proposal body" do
          expect(subject.resource_text).to eq(resource.body)
        end
      end

      describe "email_subject" do
        it "is generated correctly" do
          expect(subject.email_subject).to eq("New proposal \"#{resource_title}\" by @#{author.nickname}")
        end
      end

      describe "email_intro" do
        it "is generated correctly" do
          expect(subject.email_intro)
            .to eq("#{author.name} @#{author.nickname}, who you are following, has published a new proposal called \"#{resource_title}\". Check it out and contribute:")
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
            .to include("The <a href=\"#{resource_path}\">#{resource_title}</a> proposal was published by ")

          expect(subject.notification_title)
            .to include("<a href=\"/profiles/#{author.nickname}\">#{author.name} @#{author.nickname}</a>.")
        end
      end

      context "when the target are the participatory space followers" do
        let(:event_name) { "decidim.events.proposals.proposal_published_for_space" }
        let(:extra) { { participatory_space: true } }

        include_context "when a simple event"
        it_behaves_like "a simple event"

        describe "email_subject" do
          it "is generated correctly" do
            expect(subject.email_subject).to eq("New proposal \"#{resource_title}\" added to #{participatory_space_title}")
          end
        end

        describe "email_intro" do
          it "is generated correctly" do
            expect(subject.email_intro).to eq("The proposal \"A nice proposal\" has been added to \"#{participatory_space_title}\" that you are following.")
          end
        end

        describe "email_outro" do
          it "is generated correctly" do
            expect(subject.email_outro)
              .to include("You have received this notification because you are following \"#{participatory_space_title}\"")
          end
        end

        describe "notification_title" do
          it "is generated correctly" do
            expect(subject.notification_title)
              .to eq("The proposal <a href=\"#{resource_path}\">A nice proposal</a> has been added to #{participatory_space_title} by #{author.name} <a href=\"/profiles/#{author.nickname}\">@#{author.nickname}</a>")
          end
        end
      end

      describe "translated notifications" do
        let(:en_body) { "A nice proposal" }
        let(:body) { { en: en_body, machine_translations: { ca: "Une belle idee" } } }
        let(:resource) do
          create :proposal,
                 component: proposal_component,
                 title: { en: "A nice proposal", machine_translations: { ca: "Une belle idee" } },
                 body:
        end

        let(:en_version) { subject.resource_text["en"] }
        let(:machine_translated) { subject.resource_text["machine_translations"]["ca"] }
        let(:translatable) { true }

        it_behaves_like "a translated event"
      end
    end
  end
end
