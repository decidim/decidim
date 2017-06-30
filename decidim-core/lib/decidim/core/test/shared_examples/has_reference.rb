# frozen_string_literal: true

shared_examples_for "has reference" do
  before do
    allow(Decidim).to receive(:calculate_reference_method).and_return(nil)
  end

  context "when the reference is nil" do
    before do
      subject[:reference] = nil
    end

    context "when there is not a custom calculate reference method present" do
      it "generates a valid reference" do
        expect(subject.reference).to match(/[A-z]+/)
      end
    end

    context "when there is a custom calculate reference method present" do
      before do
        allow(Decidim).to receive(:calculate_reference_method).and_return(lambda { |resource| "1234-#{resource.id}" })
      end

      it "generates a valid reference" do
        expect(subject.reference).to eq("1234-#{subject.id}")
      end
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
