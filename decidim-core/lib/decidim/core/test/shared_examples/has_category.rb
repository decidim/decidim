# frozen_string_literal: true

shared_examples_for "has category" do
  let(:participatory_space) { subject.participatory_space }

  context "when the category is from another organization" do
    before do
      subject.category = create(:category)
    end

    it { is_expected.not_to be_valid }
  end

  context "when the category is from the same organization" do
    before do
      subject.category = create(:category, participatory_space:)
    end

    it { is_expected.to be_valid }
  end

  context "when the resource is being deleted" do
    before do
      subject.category = create(:category, participatory_space:)
      subject.save!
    end

    it "persists the categorization" do
      expect(subject.categorization).to be_persisted
    end

    it "deletes the categorization" do
      expect(Decidim::Categorization.count).to eq(1)
      expect { subject.destroy }.to change(Decidim::Categorization, :count).by(-1)
      expect(Decidim::Categorization.count).to eq(0)
    end
  end
end
