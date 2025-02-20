# frozen_string_literal: true

require "spec_helper"

shared_examples_for "endorsable" do
  context "when endorsable" do
    let(:user) { create(:user, organization: subject.organization) }
    let(:user_group) { create(:user_group, verified_at: Time.current, organization: user.organization) }

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

      context "with Organization endorsement" do
        it "returns false if the resource is not endorsed by the given organization" do
          expect(subject).not_to be_endorsed_by(user_group)
        end

        context "when there is an endorsement" do
          let!(:endorsement) { create(:endorsement, resource: subject, author: user_group) }

          it "returns false if the resource is not endorsed by the given user" do
            expect(subject).not_to be_endorsed_by(user)
          end

          it "returns true if the resource is endorsed by the given organization" do
            expect(subject).to be_endorsed_by(user_group)
          end
        end
      end
    end
  end
end
