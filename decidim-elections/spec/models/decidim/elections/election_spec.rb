# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    describe Election do
      subject { election }

      let(:election) { build(:election) }
      let(:organization) { election.component.organization }

      it { is_expected.to be_valid }
      it { is_expected.to act_as_paranoid }

      include_examples "has component"
      include_examples "resourceable"

      context "without a title" do
        let(:election) { build(:election, title: nil) }

        it { is_expected.not_to be_valid }
      end

      context "without a description" do
        let(:election) { build(:election, description: nil) }

        it { is_expected.not_to be_valid }
      end
    end
  end
end
