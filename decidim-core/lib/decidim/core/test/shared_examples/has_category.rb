# frozen_string_literal: true

shared_examples_for "has category" do
  context "when the category is from another organization" do
    before do
      subject.category = create(:category)
    end

    it { is_expected.not_to be_valid }
  end
end
