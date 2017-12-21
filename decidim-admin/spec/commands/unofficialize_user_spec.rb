# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe UnofficializeUser do
    subject { described_class.new(user) }

    let(:organization) { create :organization }

    let(:user) { create(:user, organization: organization) }

    it "broadcasts ok" do
      expect { subject.call }.to broadcast(:ok)
    end

    it "unofficializes user" do
      subject.call

      expect(user.reload).not_to be_officialized
    end
  end
end
