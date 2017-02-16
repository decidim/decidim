shared_examples_for "has reference" do
  context "when the reference is nil" do
    before do
      subject.reference = nil
    end

    it { is_expected.not_to be_valid }
  end

  context "after create" do

    it "sets the reference" do
      expect(subject.reference).not_to be_nil
    end
  end
end
