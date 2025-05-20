# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe CreateCollaborativeDraft do
      let(:form_klass) { CollaborativeDraftForm }
      let(:component) { create(:proposal_component, :with_collaborative_drafts_enabled) }
      let(:organization) { component.organization }
      let(:user) { create(:user, :confirmed, organization:) }
      let(:form) do
        form_klass.from_params(
          form_params
        ).with_context(
          current_user: user,
          current_organization: organization,
          current_participatory_space: component.participatory_space,
          current_component: component
        )
      end

      let(:author) { create(:user, organization:) }

      let(:has_address) { false }
      let(:address) { nil }
      let(:latitude) { 40.1234 }
      let(:longitude) { 2.1234 }
      let(:attachment_params) { nil }
      let(:suggested_hashtags) { [] }

      describe "call" do
        let(:form_params) do
          {
            title: "This is the collaborative draft title",
            body: "This is the collaborative draft body",
            address:,
            has_address:,
            latitude:,
            longitude:,
            add_documents: attachment_params,
            suggested_hashtags:
          }
        end

        let(:command) do
          described_class.new(form, author)
        end

        describe "when the form is not valid" do
          before do
            allow(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "does not create a collaborative draft" do
            expect do
              command.call
            end.not_to change(Decidim::Proposals::CollaborativeDraft, :count)
          end
        end

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it_behaves_like "fires an ActiveSupport::Notification event", "decidim.proposals.create_collaborative_draft:before"
          it_behaves_like "fires an ActiveSupport::Notification event", "decidim.proposals.create_collaborative_draft:after"

          it "creates a new collaborative draft" do
            expect do
              command.call
            end.to change(Decidim::Proposals::CollaborativeDraft, :count).by(1)
          end

          context "with an author" do
            it "sets the author" do
              command.call
              collaborative_draft = Decidim::Proposals::CollaborativeDraft.last

              expect(collaborative_draft.coauthorships.count).to eq(1)
              expect(collaborative_draft.authors.count).to eq(1)
              expect(collaborative_draft.authors.first).to eq(author)
            end
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:perform_action!)
              .with(
                :create,
                Decidim::Proposals::CollaborativeDraft,
                user,
                visibility: "public-only"
              ).and_call_original

            expect { command.call }.to change(Decidim::ActionLog, :count)
            action_log = Decidim::ActionLog.last
            expect(action_log.version).to be_present
          end

          context "when the has address checkbox is checked" do
            let(:has_address) { true }

            context "when the address is present" do
              let(:address) { "Some address" }

              before do
                Geocoder::Lookup::Test.add_stub(
                  address,
                  [{ "latitude" => latitude, "longitude" => longitude }]
                )
              end

              it "sets the latitude and longitude" do
                command.call
                collaborative_draft = Decidim::Proposals::CollaborativeDraft.last

                expect(collaborative_draft.latitude).to eq(latitude)
                expect(collaborative_draft.longitude).to eq(longitude)
              end
            end
          end

          context "when attachments are allowed" do
            let(:component) { create(:proposal_component, :with_attachments_allowed) }
            let(:attachment_params) do
              [
                {
                  title: "My attachment",
                  file: upload_test_file(Decidim::Dev.asset("city.jpeg"), content_type: "image/jpeg")
                }
              ]
            end

            it "creates an attachment for the proposal" do
              expect { command.call }.to change(Decidim::Attachment, :count).by(1)
              last_collaborative_draft = Decidim::Proposals::CollaborativeDraft.last
              last_attachment = Decidim::Attachment.last
              expect(last_attachment.attached_to).to eq(last_collaborative_draft)
            end

            context "when attachment is left blank" do
              let(:attachment_params) do
                {
                  title: ""
                }
              end

              it "broadcasts ok" do
                expect { command.call }.to broadcast(:ok)
              end
            end
          end
        end
      end
    end
  end
end
