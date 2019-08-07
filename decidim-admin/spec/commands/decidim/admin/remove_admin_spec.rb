# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe RemoveAdmin do
    let(:user) { create(:user, :admin, organization: current_user.organization) }
    let(:current_user) { create(:user, :admin) }
    let(:command) { described_class.new(user, current_user) }
    let(:log_info) do
      hash_including(
        extra: {
          invited_user_role: :admin
        }
      )
    end

    it "removes the admin privilege to the user" do
      command.call
      expect(user).not_to be_admin
    end

    it "broadcasts ok" do
      expect do
        command.call
      end.to broadcast(:ok)
    end

    it "tracks the change", versioning: true do
      expect(Decidim.traceability)
        .to receive(:perform_action!)
        .with("remove_from_admin", user, current_user, log_info)
        .and_call_original

      expect { command.call }.to change(Decidim::ActionLog, :count)

      action_log = Decidim::ActionLog.last
      expect(action_log.extra["version"]).to be_nil
      expect(action_log.extra)
        .to include("extra" => { "invited_user_role" => "admin" })
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
