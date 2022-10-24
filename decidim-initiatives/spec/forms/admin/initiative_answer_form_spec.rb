# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    module Admin
      describe InitiativeAnswerForm do
        subject { described_class.from_model(initiative).with_context(context) }

        let(:organization) { create(:organization) }
        let(:initiatives_type) { create(:initiatives_type, organization:) }
        let(:scope) { create(:initiatives_type_scope, type: initiatives_type) }

        let(:state) { "published" }

        let(:initiative) { create(:initiative, organization:, state:, scoped_type: scope) }
        let(:user) { create(:user, organization:) }

        let(:context) do
          {
            current_user: user,
            current_organization: organization,
            initiative:
          }
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        describe "#signature_dates_required?" do
          subject { described_class.from_model(initiative).with_context(context).signature_dates_required? }

          context "when created" do
            let(:state) { "created" }

            it { is_expected.to be(false) }
          end

          context "when published" do
            it { is_expected.to be(true) }
          end
        end
      end
    end
  end
end
