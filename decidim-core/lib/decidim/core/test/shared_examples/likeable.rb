# frozen_string_literal: true

require "spec_helper"

shared_examples_for "likeable" do
  context "when likeable" do
    let(:user) { create(:user, organization: subject.organization) }

    describe "#liked_by?" do
      context "with User like" do
        it "returns false if the resource is not liked by the given user" do
          expect(subject).not_to be_liked_by(user)
        end

        it "returns true if the resource is liked by the given user" do
          create(:like, resource: subject, author: user)
          expect(subject).to be_liked_by(user)
        end
      end
    end
  end
end
