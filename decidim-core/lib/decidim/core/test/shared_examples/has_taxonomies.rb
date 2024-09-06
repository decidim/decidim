# frozen_string_literal: true

shared_examples_for "has taxonomies" do
  describe "taxonomies" do
    context "when valid taxonomies are assigned" do
      let(:taxonomy) { create(:taxonomy, :with_parent, organization: subject.organization) }
      before do
        subject.taxonomies = [taxonomy]
      end

      it { is_expected.to be_valid }
    end

    context "when a root taxonomy is assigned" do
      let(:taxonomy) { create(:taxonomy, organization: subject.organization) }

      it "is not valid" do
        expect { subject.taxonomies = [taxonomy] }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "when a taxonomy from another organization is assigned" do
      let(:taxonomy) { create(:taxonomy, :with_parent) }
      before do
        subject.taxonomies = [taxonomy]
      end

      it { is_expected.to be_invalid }
    end
  end
end
