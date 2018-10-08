# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Conferences
    describe Partner do
      subject { partner }

      let(:partner) { build(:partner) }

      it { is_expected.to be_valid }
      it { is_expected.to be_versioned }

      describe ".default_scope" do
        it "returns speakers ordered by partner type desc and weight asc" do
          partner1 = create(:partner, partner_type: "main_promotor", weight: 2, name: "Partner 1")
          partner2 = create(:partner, partner_type: "main_promotor", weight: 1, name: "Partner 2")
          partner3 = create(:partner, partner_type: "collaborator", weight: 2, name: "Collaborator 1")
          partner4 = create(:partner, partner_type: "collaborator", weight: 1, name: "Collaborator 4")

          expected_result = [
            partner2,
            partner1,
            partner4,
            partner3
          ]

          expect(described_class.all).to eq expected_result
        end
      end

      describe "#participatory_space" do
        it "is an alias for #conference" do
          expect(partner.conference).to eq partner.participatory_space
        end
      end
    end
  end
end
