# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe CreateProposal do
        let(:form_klass) { ProposalForm }
        let(:component) { create(:proposal_component) }
        let(:organization) { component.organization }
        let(:user) { create :user, :admin, :confirmed, organization: organization }
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
        let(:has_address) { false }
        let(:address) { nil }
        let(:latitude) { 40.1234 }
        let(:longitude) { 2.1234 }
        let(:attachment_params) { nil }

        describe "call" do
          let(:form_params) do
            {
              title: "A reasonable proposal title",
              body: "A reasonable proposal body",
              address: address,
              has_address: has_address,
              attachment: attachment_params,
              user_group_id: nil
            }
          end

          let(:command) do
            described_class.new(form)
          end

          describe "when the form is not valid" do
            before do
              expect(form).to receive(:invalid?).and_return(true)
            end

            it "broadcasts invalid" do
              expect { command.call }.to broadcast(:invalid)
            end

            it "doesn't create a proposal" do
              expect do
                command.call
              end.not_to change(Decidim::Proposals::Proposal, :count)
            end
          end

          describe "when the form is valid" do
            it "broadcasts ok" do
              expect { command.call }.to broadcast(:ok)
            end

            it "creates a new proposal" do
              expect do
                command.call
              end.to change(Decidim::Proposals::Proposal, :count).by(1)
            end

            it "traces the action", versioning: true do
              expect(Decidim.traceability)
                .to receive(:create!)
                .with(Decidim::Proposals::Proposal, kind_of(Decidim::User), kind_of(Hash), visibility: "all")
                .and_call_original

              expect { command.call }.to change(Decidim::ActionLog, :count)
              action_log = Decidim::ActionLog.last
              expect(action_log.version).to be_present
            end

            context "when geocoding is enabled" do
              let(:component) { create(:proposal_component, :with_geocoding_enabled) }

              context "when the has address checkbox is checked" do
                let(:has_address) { true }

                context "when the address is present" do
                  let(:address) { "Carrer Pare Llaurador 113, baixos, 08224 Terrassa" }

                  before do
                    stub_geocoding(address, [latitude, longitude])
                  end

                  it "sets the latitude and longitude" do
                    command.call
                    proposal = Decidim::Proposals::Proposal.last

                    expect(proposal.latitude).to eq(latitude)
                    expect(proposal.longitude).to eq(longitude)
                  end
                end
              end
            end

            context "when attachments are allowed", processing_uploads_for: Decidim::AttachmentUploader do
              let(:component) { create(:proposal_component, :with_attachments_allowed) }
              let(:attachment_params) do
                {
                  title: "My attachment",
                  file: Decidim::Dev.test_file("city.jpeg", "image/jpeg")
                }
              end

              it "creates an atachment for the proposal" do
                expect { command.call }.to change(Decidim::Attachment, :count).by(1)
                last_proposal = Decidim::Proposals::Proposal.last
                last_attachment = Decidim::Attachment.last
                expect(last_attachment.attached_to).to eq(last_proposal)
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
end
