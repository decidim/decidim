# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe GlobalModerationsController do
      routes { Decidim::Admin::Engine.routes }

      let(:reportable) { create(:dummy_resource) }
      let(:moderation) { create(:moderation, reportable:, report_count: 1, hidden_at: Time.current) }
      let!(:report) { create(:report, moderation:) }
      let(:current_user) { create(:user, :admin, :confirmed, organization: reportable.participatory_space.organization) }

      before do
        request.env["decidim.current_organization"] = reportable.participatory_space.organization
      end

      describe "unhide" do
        context "when the user is signed im" do
          before do
            sign_in current_user, scope: :user
          end

          context "when the request is ok" do
            it "redirects hidden moderations path with notice" do
              put :unhide, xhr: true, params: { id: moderation.id }
              expect(flash[:notice]).to be_present
              expect(response).to redirect_to(moderations_path(hidden: true))
            end
          end

          context "when the request is invalid" do
            let(:moderation) { create(:moderation, reportable:, report_count: 1, hidden_at: nil) }

            it "redirects hidden moderations path with alert" do
              put :unhide, xhr: true, params: { id: moderation.id }
              expect(flash[:alert]).to be_present
              expect(response).to redirect_to(moderations_path(hidden: true))
            end
          end

          context "when the resource parent is hidden" do
            let(:comment) { create(:comment, commentable: reportable, author: current_user) }
            let(:comment_moderation) { create(:moderation, reportable: comment, report_count: 1, hidden_at: Time.current) }

            it "redirects hidden moderations path with alert" do
              put :unhide, xhr: true, params: { id: comment_moderation.id }
              expect(flash[:alert]).to be_present
              expect(response).to redirect_to(moderations_path(hidden: true))
            end
          end
        end
      end
    end
  end
end
