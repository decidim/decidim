# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe PublishProposalEvent do
      let(:resource) { create :proposal, title: "A nice proposal" }
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
              .to eq("The proposal <a href=\"#{resource_path}\">A nice proposal</a> has been added to #{participatory_space_title}")
          end
        end
      end

      describe "translated notifications" do
        context "when it is not machine machine translated" do

          let(:resource) do
            create :proposal,
                   title: { "en": "A nice proposal", "machine_translations": {"ca": "Une belle idee" } },
                   body: { "en": "A nice proposal", "machine_translations": {"ca": "Une belle idee" } }
          end

          before do
            organization = resource.organization
            organization.update enable_machine_translations: false
          end

          it "does not have machine translations" do
            expect(subject.perform_translation?).to eq(false)
          end

          it "does not have machine translations" do
            expect(subject.translation_missing?).to eq(false)
          end

          it "does not have machine translations" do
            expect(subject.content_in_same_language?).to eq(false)
          end

          it "does not offer an alternate translation" do
            expect(subject.safe_resource_text).to eq(subject.resource_text["en"])
          end

          it "does not offer an alternate translation" do
            expect(subject.safe_resource_text).to eq(subject.resource_text["en"])
          end
        end

        context "when is machine machine translated" do
          let(:user) { create :user, organization: organization, locale: "ca" }

          let(:resource) do
            create :proposal,
                   title: { "en": "A nice proposal", "machine_translations": {"ca": "Une belle idee" } },
                   body: { "en": "A nice proposal", "machine_translations": {"ca": "Une belle idee" } }
          end

          before do
            organization = resource.organization
            organization.update enable_machine_translations: true
          end

          around(:each) do |example|
            I18n.with_locale(user.locale) { example.run }
          end

          context "when priority is original" do
            before do
              organization.update machine_translation_display_priority: "original"
            end

            it "does not have machine translations" do
              expect(subject.perform_translation?).to eq(true)
            end

            it "does not have machine translations" do
              expect(subject.translation_missing?).to eq(false)
            end

            it "does not have machine translations" do
              expect(subject.content_in_same_language?).to eq(false)
            end

            it "does not offer an alternate translation" do
              expect(subject.safe_resource_text).to eq(subject.resource_text["en"])
            end

            it "does not offer an alternate translation" do
              expect(subject.safe_resource_translated_text).to eq(subject.resource_text["machine_translations"]["ca"])
            end

            context "when translation is not available" do

              let(:resource) do
                create :proposal,
                       title: { "en": "A nice proposal" },
                       body: { "en": "A nice proposal" }
              end
              it "does not have machine translations" do
                expect(subject.perform_translation?).to eq(true)
              end

              it "does not have machine translations" do
                expect(subject.translation_missing?).to eq(true)
              end

              it "does not have machine translations" do
                expect(subject.content_in_same_language?).to eq(false)
              end

              it "does not offer an alternate translation" do
                expect(subject.safe_resource_text).to eq(subject.resource_text["en"])
              end

              it "does not offer an alternate translation" do
                expect(subject.safe_resource_translated_text).to eq(subject.resource_text["en"])
              end
            end
          end

          context "when priority is translation" do

            let(:resource) do
              create :proposal,
                     title: { "en": "A nice proposal", "machine_translations": {"ca": "Une belle idee" } },
                     body: { "en": "A nice proposal", "machine_translations": {"ca": "Une belle idee" } }
            end

            before do
              organization.update machine_translation_display_priority: "translation"
            end

            it "does not have machine translations" do
              expect(subject.perform_translation?).to eq(true)
            end

            it "does not have machine translations" do
              expect(subject.translation_missing?).to eq(false)
            end

            it "does not have machine translations" do
              expect(subject.content_in_same_language?).to eq(false)
            end

            it "does not offer an alternate translation" do
              expect(subject.safe_resource_text).to eq(subject.resource_text["en"])
            end

            it "does not offer an alternate translation" do
              expect(subject.safe_resource_translated_text).to eq(subject.resource_text["machine_translations"]["ca"])
            end

            context "when translation is not available" do

              let(:resource) do
                create :proposal,
                       title: { "en": "A nice proposal" },
                       body: { "en": "A nice proposal" }
              end

              it "does not have machine translations" do
                expect(subject.perform_translation?).to eq(true)
              end

              it "does not have machine translations" do
                expect(subject.translation_missing?).to eq(true)
              end

              it "does not have machine translations" do
                expect(subject.content_in_same_language?).to eq(false)
              end

              it "does not offer an alternate translation" do
                expect(subject.safe_resource_text).to eq(subject.resource_text["en"])
              end

              it "does not offer an alternate translation" do
                expect(subject.safe_resource_translated_text).to eq(subject.resource_text["en"])
              end

            end
          end
        end
      end
    end
  end
end
