# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Debates
    module Admin
      describe DebatesController do
        routes { Decidim::Debates::AdminEngine.routes }

        let(:organization) { create(:organization) }
        let(:current_user) { create(:user, :confirmed, :admin, organization:) }
        let(:participatory_space) { create(:participatory_process, organization:) }
        let!(:component) { create(:debates_component, participatory_space:) }
        let(:debate) { create(:debate, component:) }
        let(:params) { { id: debate.id } }

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.current_component"] = component
          sign_in current_user
        end

        describe "PATCH soft_delete" do
          it "soft deletes the debate" do
            expect(Decidim::Commands::SoftDeleteResource).to receive(:call).with(debate, current_user).and_call_original

            patch(:soft_delete, params:)

            expect(response).to redirect_to debates_path
            expect(flash[:notice]).to eq(I18n.t("debates.soft_delete.success", scope: "decidim.debates.admin"))
            expect(debate.reload.deleted_at).not_to be_nil
          end
        end

        describe "PATCH restore" do
          before do
            debate.update!(deleted_at: Time.current)
          end

          it "restores the debate" do
            expect(Decidim::Commands::RestoreResource).to receive(:call).with(debate, current_user).and_call_original

            patch(:restore, params:)

            expect(response).to redirect_to manage_trash_debates_path
            expect(flash[:notice]).to eq(I18n.t("debates.restore.success", scope: "decidim.debates.admin"))
            expect(debate.reload.deleted_at).to be_nil
          end
        end

        describe "GET manage_trash" do
          let!(:deleted_debate) { create(:debate, component:, deleted_at: Time.current) }
          let!(:active_debate) { create(:debate, component:) }
          let(:deleted_debates) { controller.view_context.trashable_deleted_collection }

          it "lists only deleted debates" do
            get :manage_trash

            expect(response).to have_http_status(:ok)
            expect(deleted_debates).to include(deleted_debate)
            expect(deleted_debates).not_to include(active_debate)
          end

          it "renders the deleted debates template" do
            get :manage_trash

            expect(response).to render_template(:manage_trash)
          end
        end
      end
    end
  end
end
