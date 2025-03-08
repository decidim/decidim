# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe MergeProposals do
        describe "call" do
          let!(:proposals) { create_list(:proposal, 3, component: current_component, taxonomies:) }
          let!(:current_component) { create(:proposal_component) }
          let!(:target_component) { create(:proposal_component, participatory_space: current_component.participatory_space) }
          let(:taxonomies) { create_list(:taxonomy, 3, :with_parent, organization: current_component.organization) }
          let(:user) { create(:user, :confirmed, :admin, organization:) }
          let(:organization) { create(:organization) }
          let(:author) { create(:user, organization:) }
          let(:form) do
            instance_double(
              ProposalsMergeForm,
              current_component:,
              current_organization: current_component.organization,
              target_component:,
              proposals:,
              valid?: valid,
              same_component?: same_component,
              current_user: create(:user, :admin, organization: current_component.organization),
              add_photos: [],
              add_documents: [],
              title: { "en" => "Valid Long Proposal Title" },
              body: { "en" => "Valid body text" },
              address: "",
              latitude: "",
              longitude: "",
              created_in_meeting: false,
              created_in_meeting?: false,
              author:,
              documents: []
            )
          end
          let(:command) { described_class.new(form) }
          let(:same_component) { false }

          describe "when the form is not valid" do
            let(:valid) { false }

            it "broadcasts invalid" do
              expect { command.call }.to broadcast(:invalid)
            end

            it "does not create the proposal" do
              expect do
                command.call
              end.not_to change(Proposal, :count)
            end
          end

          describe "when the form is valid" do
            let(:valid) { true }

            context "when process_attachments? is true" do
              before do
                allow(command).to receive(:process_attachments?).and_return(true)
                allow(command).to receive(:build_attachments)
              end

              context "and attachments are invalid" do
                before do
                  allow(command).to receive(:attachments_invalid?).and_return(true)
                end

                it "broadcasts invalid and stops processing" do
                  expect { command.call }.to broadcast(:invalid)
                  expect(command).to have_received(:build_attachments)
                end
              end

              context "and attachments are valid" do
                before do
                  allow(command).to receive(:process_attachments?).and_return(true)
                  allow(command).to receive(:attachments_invalid?).and_return(false)
                  allow(command).to receive(:build_attachments).and_call_original
                end

                let(:valid_photo) do
                  { file: upload_test_file(Decidim::Dev.asset("city.jpeg"), content_type: "image/jpeg") }
                end

                let(:valid_document) do
                  { file: upload_test_file(Decidim::Dev.asset("Exampledocument.pdf"), content_type: "application/pdf") }
                end

                let(:form) do
                  instance_double(
                    ProposalsMergeForm,
                    current_component:,
                    current_organization: current_component.organization,
                    target_component:,
                    proposals:,
                    valid?: true,
                    same_component?: same_component,
                    current_user: create(:user, :admin, organization: current_component.organization),
                    add_photos: [valid_photo],
                    add_documents: [valid_document],
                    title: { "en" => "Valid very Long Proposal Title" },
                    body: { "en" => "Valid body text" },
                    address: "",
                    latitude: "",
                    longitude: "",
                    created_in_meeting: false,
                    created_in_meeting?: false,
                    author:
                  )
                end

                it "builds attachments and proceeds" do
                  expect(command).to receive(:create_attachments).with(first_weight: anything)
                  expect { command.call }.to broadcast(:ok)
                end
              end
            end

            describe "when process_attachments? is false" do
              before do
                allow(command).to receive(:process_attachments?).and_return(false)
                allow(command).to receive(:build_attachments)
              end

              it "does not process attachments" do
                command.call
                expect(command).not_to have_received(:build_attachments)
              end
            end

            context "when created_in_meeting is false" do
              let(:created_in_meeting) { false }

              it "does not link the proposal to the meeting" do
                command.call

                proposal = Proposal.where(component: target_component).last
                linked = proposal.linked_resources(:proposals, "proposals_from_meeting")

                expect(linked).to be_empty
              end
            end

            it "broadcasts ok" do
              expect { command.call }.to broadcast(:ok)
            end

            it "creates a proposal in the new component" do
              expect do
                command.call
              end.to change { Proposal.where(component: target_component).count }.by(1)
            end

            it "links the proposals" do
              command.call
              proposal = Proposal.where(component: target_component).last

              linked = proposal.linked_resources(:proposals, "merged_from_component")

              expect(linked).to match_array(proposals)
            end

            it "only merges wanted attributes" do
              command.call
              new_proposal = Proposal.where(component: target_component).last
              proposal = proposals.first

              expect(new_proposal.title).to eq({ "en" => "Valid Long Proposal Title" })
              expect(new_proposal.body).to eq({ "en" => "Valid body text" })
              expect(new_proposal.creator_author).to eq(current_component.organization)
              expect(new_proposal.taxonomies).to eq(proposal.taxonomies)

              expect(new_proposal.state).to be_nil
              expect(new_proposal.answer).to be_nil
              expect(new_proposal.answered_at).to be_nil
              expect(new_proposal.reference).not_to eq(proposal.reference)
            end

            context "when merging from the same component" do
              let(:same_component) { true }
              let(:target_component) { current_component }

              it "shows the original proposals as withdrawn" do
                command.call

                expect(form.proposals.pluck(:withdrawn_at)).to all(be_present)
              end

              it "verifies the merged proposal in the target component" do
                other_component = create(:proposal_component, participatory_space: current_component.participatory_space)
                other_proposals = create_list(:proposal, 3, component: other_component)

                proposals.each_with_index do |proposal, index|
                  proposal.link_resources(other_proposals[index], "merged_from_component")
                  expect(proposal.linked_resources(:proposals, "merged_from_component")).to include(other_proposals[index])
                end

                command.call

                merged_proposal = Proposal.where(component: target_component).last
                expect(merged_proposal).not_to be_nil
              end
            end
          end
        end
      end
    end
  end
end
