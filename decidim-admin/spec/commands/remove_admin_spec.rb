# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe RemoveAdmin do
    let(:user) { create(:user, :admin, organization: current_user.organization) }
    let(:current_user) { create(:user, :admin) }
    let(:command) { described_class.new(user, current_user) }

    it "removes the admin privilege to the user" do
      command.call
      expect(user).not_to be_admin
    end

    it "broadcasts ok" do
      expect do
        command.call
      end.to broadcast(:ok)
    end

    it "tracks the change" do
      expect(Decidim::ActionLogger)
        .to receive(:log)
        .with("remove_from_admin", current_user, user, a_kind_of(Hash))

        command.call
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
