# frozen_string_literal: true

require "spec_helper"

shared_examples_for "authorable" do
  describe "validations" do
    context "when the author is from another organization" do
      before do
        subject.author = create(:user)
      end

      it { is_expected.to be_invalid }
    end
  end
end
