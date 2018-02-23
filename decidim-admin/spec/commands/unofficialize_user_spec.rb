# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe UnofficializeUser do
    subject { described_class.new(user, current_user) }

    let(:organization) { create :organization }
    let(:user) { create(:user, organization: organization) }
    let(:current_user) { create(:user, organization: organization) }

    it "broadcasts ok" do
      expect { subject.call }.to broadcast(:ok)
    end

    it "traces the update" do
      expect(Decidim::ActionLogger)
        .to receive(:log)
        .with("unofficialize", current_user, user, an_instance_of(Hash))

      subject.call
    end

    it "unofficializes user" do
      subject.call

      expect(user.reload).not_to be_officialized
    end
  end
end
