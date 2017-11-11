# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Notification do
    subject { notification }

    let(:notification) { build(:notification) }

    it { is_expected.to be_valid }

    describe "validations" do
      context "without user" do
        let(:notification) { build(:notification, user: nil) }

        it { is_expected.not_to be_valid }
      end

      context "without resource" do
        let(:notification) { build(:notification, resource: nil) }

        it { is_expected.not_to be_valid }
      end
    end
  end
end
