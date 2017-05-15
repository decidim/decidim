# frozen_string_literal: true
require "spec_helper"

module Decidim
  describe RemoveUserRole do
    let(:user) { create(:user, :admin) }
    let(:command) { described_class.new(user, "admin") }

    it "removes the role from the user" do
      command.call
      expect(user.role?("admin")).to be_falsey
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
