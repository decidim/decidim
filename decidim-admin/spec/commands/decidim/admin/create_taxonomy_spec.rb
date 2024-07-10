# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe CreateTaxonomy do
    subject { described_class.new(form) }

    let(:organization) { create(:organization) }
    let(:user) { create(:user, :admin, :confirmed, organization:) }
    let(:form) do
      double(
        invalid?: invalid,
        current_user: user,
        name: { en: "New Taxonomy" },
        weight: 1,
        parent_id: nil,
        organization:
      )
    end

    let(:invalid) { false }

    context "when the form is not valid" do
      let(:invalid) { true }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the form is valid" do
      it "creates a new taxonomy" do
        expect { subject.call }.to change(Decidim::Taxonomy, :count).by(1)
      end

      it "traces the action" do
        expect(Decidim.traceability)
          .to receive(:create!)
          .with(anything, user, hash_including(:name, :weight, :parent_id, :organization))
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count).by(1)
      end
    end
  end
end
