# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe UpdateProposal do
      let(:form_klass) { ProposalForm }

      let(:component) { create(:proposal_component) }
      let(:organization) { component.organization }
      let(:form) do
        form_klass.from_params(
          form_params
        ).with_context(
          current_organization: organization,
          current_participatory_space: component.participatory_space,
          current_component: component
        )
      end

      let!(:proposal) { create :proposal, component: component, author: author }
      let(:author) { create(:user, organization: organization) }

      let(:user_group) do
        create(:user_group, :verified, organization: organization, users: [author])
      end

      let(:has_address) { false }
      let(:address) { nil }
      let(:latitude) { 40.1234 }
      let(:longitude) { 2.1234 }

      describe "call" do
        let(:form_params) do
          {
            title: "a reasonable proposal title",
            body: "a reasonable proposal body",
            address: address,
            has_address: has_address,
            user_group_id: user_group.try(:id)
          }
        end

        let(:command) do
          described_class.new(form, author, proposal)
        end

        describe "when the form is not valid" do
          before do
            expect(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't update the proposal" do
            expect do
              command.call
            end.not_to change(proposal, :title)
          end
        end

        describe "when the proposal is not editable by the user" do
          before do
            expect(proposal).to receive(:editable_by?).and_return(false)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't update the proposal" do
            expect do
              command.call
            end.not_to change(proposal, :title)
          end
        end

        context "when the author changinng the author to one that has reached the proposal limit" do
          let!(:other_proposal) { create :proposal, component: component, author: author, user_group: user_group }
          let(:component) { create(:proposal_component, :with_proposal_limit) }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end
        end

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "format title and body" do
            command.call
            expect(proposal.title).to eq("A reasonable proposal title")
            expect(proposal.body).to eq("A reasonable proposal body")
          end

          it "updates the proposal" do
            expect do
              command.call
            end.to change(proposal, :title)
          end

          context "with an author" do
            let(:user_group) { nil }

            it "sets the author" do
              command.call
              proposal = Decidim::Proposals::Proposal.last

              expect(proposal.author).to eq(author)
              expect(proposal.user_group).to eq(nil)
            end
          end

          context "with a user group" do
            it "sets the user group" do
              command.call
              proposal = Decidim::Proposals::Proposal.last

              expect(proposal.author).to eq(author)
              expect(proposal.user_group).to eq(user_group)
            end
          end

          context "when geocoding is enabled" do
            let(:component) { create(:proposal_component, :with_geocoding_enabled) }

            context "when the has address checkbox is checked" do
              let(:has_address) { true }

              context "when the address is present" do
                let(:address) { "Carrer Pare Llaurador 113, baixos, 08224 Terrassa" }

                before do
                  Geocoder::Lookup::Test.add_stub(
                    address,
                    [{ "latitude" => latitude, "longitude" => longitude }]
                  )
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
        end
      end
    end
  end
end
