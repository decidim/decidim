# frozen_string_literal: true

shared_examples_for "has reference" do
  context "when the reference is nil" do
    before do
      subject[:reference] = nil
    end

    context "when there is not a custom resource reference generator present" do
      it "generates a valid reference" do
        expect(subject.reference).to match(/[A-z]+/)
      end
    end

    context "when there is a custom resource reference generator present" do
      before do
        allow(Decidim).to receive(:reference_generator).and_return(->(resource, _component) { "1234-#{resource.id}" })
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
      expect(subject.reload.reference).not_to be_blank
    end
  end
end
