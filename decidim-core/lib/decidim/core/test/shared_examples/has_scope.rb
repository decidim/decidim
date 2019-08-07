# frozen_string_literal: true

shared_examples_for "has scope" do
  context "when the scope is from another organization" do
    before do
      subject.scope = create(:scope)
    end

    it { is_expected.not_to be_valid }
  end
end
