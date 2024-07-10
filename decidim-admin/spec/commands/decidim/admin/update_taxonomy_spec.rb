# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe UpdateTaxonomy do
    subject { described_class.new(form, taxonomy) }

    let(:organization) { create(:organization) }
    let(:user) { create(:user, :admin, :confirmed, organization:) }
    let(:taxonomy) { create(:taxonomy, organization:) }
    let(:form) do
      double(
        invalid?: invalid,
        current_user: user,
        name:,
        weight:,
        parent_id:
      )
    end

    let(:name) { { en: "New name" } }
    let(:weight) { 1 }
    let(:parent_id) { 1 }
    let(:invalid) { false }

    context "when the form is not valid" do
      let(:invalid) { true }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the form is valid" do
      before do
        subject.call
        taxonomy.reload
      end

      it "updates the name of the taxonomy" do
        expect(taxonomy.name['en']).to eq("New name")
      end

      it "updates the weight of the taxonomy" do
        expect(taxonomy.weight).to eq(1)
      end

      it "updates the parent_id of the taxonomy" do
        expect(taxonomy.parent_id).to eq(1)
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:update!)
          .with(taxonomy, user, hash_including(:name, :weight, :parent_id))
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end
    end
  end
end
