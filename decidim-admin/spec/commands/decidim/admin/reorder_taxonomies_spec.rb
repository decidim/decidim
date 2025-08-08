# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe ReorderTaxonomies do
    subject { described_class.new(*args) }

    let(:args) { [organization, order] }
    let(:organization) { create(:organization) }

    let!(:taxonomy1) { create(:taxonomy, weight: 1, organization:) }
    let!(:taxonomy2) { create(:taxonomy, weight: 2, organization:) }
    let!(:taxonomy3) { create(:taxonomy, weight: 3, organization:) }
    let!(:taxonomy4) { create(:taxonomy, weight: 40, organization:) }
    let!(:external_taxonomy) { create(:taxonomy, weight: 11) }

    let(:order) { [taxonomy3.id, taxonomy1.id, taxonomy2.id] }

    context "when the order is nil" do
      let(:order) { nil }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the order is empty" do
      let(:order) { [] }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the order is valid" do
      it "is valid" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "reorders the blocks" do
        subject.call
        taxonomy1.reload
        taxonomy2.reload
        taxonomy3.reload
        taxonomy4.reload
        external_taxonomy.reload

        expect(taxonomy3.weight).to eq 1
        expect(taxonomy1.weight).to eq 2
        expect(taxonomy2.weight).to eq 3
        expect(taxonomy4.weight).to eq 40
        expect(external_taxonomy.weight).to eq 11
      end
    end
  end
end
