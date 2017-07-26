# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe ExpireImpersonationJob do
      let(:user) { create(:user, :managed) }
      let(:current_user) { create(:user, :admin, organization: user.organization) }
      let!(:impersonation_log) { create(:impersonation_log, admin: current_user, user: user) }

      it "closes impersonation session" do
        ExpireImpersonationJob.perform_now(user, current_user)
        expect(impersonation_log.reload.end_at).not_to be_nil
      end
    end
  end
end
