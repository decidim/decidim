# frozen_string_literal: true

shared_examples_for "has reference" do
  context "when the reference is nil" do
    before do
      subject[:reference] = nil
    end

    it "generates a valid reference" do
      expect(subject.reference).to match(/[A-z]+/)
    end
  end

  context "when the reference is already set" do
    before do
      subject[:reference] = "ARBITRARYREF"
    end

    it "keeps the pre-existing reference" do
      expect(subject.reference).to eq("ARBITRARYREF")
    end
  end

  context "when saving" do
    it "stores the reference" do
      subject.reference = nil
      subject.save!
      expect(subject.reload.reference).to_not be_blank
    end
  end
end
