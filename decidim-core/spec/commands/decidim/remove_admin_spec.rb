# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe RemoveAdmin do
    let(:user) { create(:user, :admin) }
    let(:command) { described_class.new(user) }

    it "removes the admin privilege to the user" do
      command.call
      expect(user).not_to be_admin
    end

    it "broadcasts ok" do
      expect do
        command.call
      end.to broadcast(:ok)
    end

    context "when no user given" do
      let(:user) { nil }

      it "broadcasts invalid" do
        expect do
          command.call
        end.to broadcast(:invalid)
      end
    end
  end
end
