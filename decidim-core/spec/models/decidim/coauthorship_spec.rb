# frozen_string_literal: true

require "spec_helper"

describe Decidim::Coauthorship do
  subject { coauthorship }

  let(:coauthorship) { build(:coauthorship) }

  describe "validations" do
    context "when the coauthorable is nil" do
      before do
        coauthorship.coauthorable = nil
      end

      it { is_expected.to be_invalid }
    end

    context "when the user group is not verified" do
      it "is not valid" do
        user_group = create(:user_group)
        create(:user_group_membership, user: subject.author, user_group:)
        subject.user_group = user_group
        expect(subject).not_to be_valid
      end
    end

    context "when the author doesn't have a membership of the user group" do
      it "is not valid" do
        user_group = create(:user_group, :verified)
        subject.user_group = user_group
        expect(subject).not_to be_valid
      end
    end

    context "when the author is from another organization" do
      before do
        subject.author = create(:user)
      end

      it { is_expected.to be_invalid }
    end
  end
end
