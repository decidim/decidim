# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    module Admin
      describe InitiativeForm do
        subject { described_class.from_model(initiative).with_context(context) }

        let(:organization) { create(:organization) }
        let(:initiatives_type) { create(:initiatives_type, organization: organization) }
        let(:scope) { create(:initiatives_type_scope, type: initiatives_type) }

        let(:state) { "validating" }
        let(:initiative) { create(:initiative, organization: organization, state: state, scoped_type: scope) }

        let(:context) do
          {
            current_organization: organization,
            current_component: nil,
            initiative: initiative
          }
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        describe "#signature_type_updatable?" do
          subject { described_class.from_model(initiative).with_context(context).signature_type_updatable? }

          context "when created" do
            let(:state) { "created" }

            it { is_expected.to eq(true) }
          end

          context "when any other state" do
            it { is_expected.to eq(false) }
          end
        end
      end
    end
  end
end
