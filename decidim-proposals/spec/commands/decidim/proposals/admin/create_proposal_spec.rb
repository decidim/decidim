# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe CreateProposal do
        let(:form_klass) { ProposalForm }
        let(:component) { create(:proposal_component) }
        let(:organization) { component.organization }
        let(:meeting_component) { create(:meeting_component, participatory_space: component.participatory_space) }
        let(:meetings) { create_list(:meeting, 3, :published, component: meeting_component) }
        let(:user) { create :user, :admin, :confirmed, organization: }
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
        let(:uploaded_photos) { [] }
        let(:photos) { [] }
        let(:created_in_meeting) { false }
        let(:meeting_id) { nil }

        describe "call" do
          let(:form_params) do
            {
              title: { en: "A reasonable proposal title" },
              body: { en: "A reasonable proposal body" },
              address:,
              has_address:,
              attachment: attachment_params,
              photos:,
              add_photos: uploaded_photos,
              created_in_meeting:,
              meeting_id:,
              user_group_id: nil
            }
          end

          let(:command) do
            described_class.new(form)
          end

          describe "when the form is not valid" do
            before do
              allow(form).to receive(:invalid?).and_return(true)
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

            context "when proposal comes from a meeting" do
              let(:created_in_meeting) { true }
              let(:meeting_id) { meetings.first.id }
              let(:meeting_as_author) { meetings.first }

              it "sets the meeting as author" do
                command.call

                expect(Decidim::Proposals::Proposal.last.authors).to include(meeting_as_author)
              end

              it "links the proposal and the meeting" do
                command.call
                proposal = Decidim::Proposals::Proposal.last
                proposal_linked_meetings = proposal.linked_resources(:meeting, "proposals_from_meeting")

                expect(proposal_linked_meetings).to include(meeting_as_author)
              end

              context "when the meeting is already linked to other proposals" do
                let(:another_proposal) { create :proposal, component: }

                it "keeps the old proposals linked" do
                  another_proposal.link_resources(meeting_as_author, "proposals_from_meeting")
                  command.call
                  proposal = Decidim::Proposals::Proposal.last
                  linked_proposals = meeting_as_author.linked_resources(:proposal, "proposals_from_meeting")

                  expect(linked_proposals).to match_array([proposal, another_proposal])
                end
              end
            end

            context "when proposal is official" do
              it "sets the organization as author" do
                command.call

                expect(Decidim::Proposals::Proposal.last.authors).to include(organization)
              end

              it "create a searchable resource" do
                expect { command.call }.to change(Decidim::SearchableResource, :count).by_at_least(1)
              end
            end

            it "traces the action", versioning: true do
              expect(Decidim.traceability)
                .to receive(:perform_action!)
                .with(:create, Decidim::Proposals::Proposal, kind_of(Decidim::User), visibility: "all")
                .and_call_original

              expect { command.call }.to change(Decidim::ActionLog, :count)
              action_log = Decidim::ActionLog.last
              expect(action_log.version).to be_present
            end

            it "notifies the space followers" do
              follower = create(:user, organization: component.participatory_space.organization)
              create(:follow, followable: component.participatory_space, user: follower)

              expect(Decidim::EventsManager)
                .to receive(:publish)
                .with(
                  event: "decidim.events.proposals.proposal_published",
                  event_class: Decidim::Proposals::PublishProposalEvent,
                  resource: kind_of(Decidim::Proposals::Proposal),
                  followers: [follower],
                  extra: {
                    participatory_space: true
                  }
                )

              command.call
            end

            context "when geocoding is enabled" do
              let(:component) { create(:proposal_component, :with_geocoding_enabled) }

              context "when the has address checkbox is checked" do
                let(:has_address) { true }

                context "when the address is present" do
                  let(:address) { "Some address" }

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

            context "when attachments are allowed" do
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

            context "when galleries are allowed" do
              it_behaves_like "admin creates resource gallery" do
                let(:component) { create(:proposal_component, :with_attachments_allowed) }
                let(:command) { described_class.new(form) }
                let(:resource_class) { Decidim::Proposals::Proposal }
                let(:attachment_params) { { title: "" } }
              end
            end
          end
        end
      end
    end
  end
end
