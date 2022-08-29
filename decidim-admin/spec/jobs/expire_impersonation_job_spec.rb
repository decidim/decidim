# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe ExpireImpersonationJob do
      let(:user) { create(:user, :managed) }
      let(:current_user) { create(:user, :admin, organization: user.organization) }
      let!(:impersonation_log) { create(:impersonation_log, admin: current_user, user:) }

      it "marks the impersonation as expired" do
        ExpireImpersonationJob.perform_now(user, current_user)
        expect(impersonation_log.reload).to be_expired
      end

      context "when the impersonation is already ended" do
        before do
          impersonation_log.update!(ended_at: Time.current)
        end

        it "doesn't expires it" do
          ExpireImpersonationJob.perform_now(user, current_user)
          expect(impersonation_log.reload).not_to be_expired
        end
      end
    end
  end
end
