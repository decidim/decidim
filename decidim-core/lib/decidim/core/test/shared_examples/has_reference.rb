shared_examples_for "has reference" do
  context "when the reference is nil" do
    before do
      subject.reference = nil
    end

    it { is_expected.not_to be_valid }
  end
end
