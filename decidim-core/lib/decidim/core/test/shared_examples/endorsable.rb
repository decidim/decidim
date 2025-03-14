# frozen_string_literal: true

require "spec_helper"

shared_examples_for "endorsable" do
  context "when endorsable" do
    let(:user) { create(:user, organization: subject.organization) }

    describe "#endorsed_by?" do
      context "with User endorsement" do
        it "returns false if the resource is not endorsed by the given user" do
          expect(subject).not_to be_endorsed_by(user)
        end

        it "returns true if the resource is endorsed by the given user" do
          create(:endorsement, resource: subject, author: user)
          expect(subject).to be_endorsed_by(user)
        end
      end
    end
  end
end
