# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Proposals
    describe Proposal do
      subject { build(:proposal) }

      it { is_expected.to be_valid }

      context "when the category is from another feature" do
        subject { build(:proposal, category: create(:category))}

        it { is_expected.to be_invalid}
      end

      context "when the author is from another organization" do
        subject { build(:proposal, author: create(:user))}

        it { is_expected.to be_invalid}
      end

      context "when the scope is from another organization" do
        subject { build(:proposal, scope: create(:scope))}

        it { is_expected.to be_invalid}
      end
    end
  end
end
