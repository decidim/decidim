# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::Admin::UpdateProposal do
  let(:form_klass) { Decidim::Proposals::Admin::ProposalForm }

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

  let!(:proposal) { create :proposal, :official, component: component }

  let(:has_address) { false }
  let(:address) { nil }
  let(:latitude) { 40.1234 }
  let(:longitude) { 2.1234 }

  describe "call" do
    let(:form_params) do
      {
        title: "A reasonable proposal title",
        body: "A reasonable proposal body",
        address: address,
        has_address: has_address
      }
    end

    let(:command) do
      described_class.new(form, proposal)
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

    describe "when the form is valid" do
      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "updates the proposal" do
        expect do
          command.call
        end.to change(proposal, :title)
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
    end
  end
end
