# frozen_string_literal: true

require "spec_helper"

# users of this test should delare the `subject` variable.
shared_examples "acts as author" do
  describe "presenter" do
    it "returns an instance of the presenter for this author" do
      expect(subject.presenter).to be_present
    end
  end
end
