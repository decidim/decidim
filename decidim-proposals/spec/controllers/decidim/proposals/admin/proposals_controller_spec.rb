# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::Admin::ProposalsController do
  routes { Decidim::Proposals::AdminEngine.routes }

  let(:user) { create(:user, :confirmed, :admin, organization: component.organization) }

  before do
    request.env["decidim.current_organization"] = component.organization
    request.env["decidim.current_participatory_space"] = component.participatory_space
    request.env["decidim.current_component"] = component
    sign_in user
  end

  describe "PATCH update" do
    let(:component) { create(:proposal_component, :with_creation_enabled, :with_attachments_allowed) }
    let(:proposal) { create(:proposal, :official, component:) }
    let(:proposal_params) do
      {
        title: { en: "Lorem ipsum dolor sit amet, consectetur adipiscing elit" },
        body: { en: "Ut sed dolor vitae purus volutpat venenatis. Donec sit amet sagittis sapien. Curabitur rhoncus ullamcorper feugiat. Aliquam et magna metus." },
        attachment: {
          title: "",
          file: nil
        }
      }
    end
    let(:params) do
      {
        id: proposal.id,
        proposal: proposal_params
      }
    end

    it "updates the proposal" do
      allow(controller).to receive(:proposals_path).and_return("/proposals")

      patch(:update, params:)

      expect(flash[:notice]).not_to be_empty
      expect(response).to have_http_status(:found)
    end

    context "when the existing proposal has photos and there are other errors on the form" do
      include_context "with controller rendering the view" do
        let(:proposal_params) do
          {
            title: { en: "" },
            # When the proposal has existing photos or documents, their IDs
            # will be sent as Strings in the form payload.
            photos: proposal.photos.map { |a| a.id.to_s },
            attachment: { title: "", file: nil }
          }
        end
        let(:proposal) { create(:proposal, :official, :with_photo, component:) }

        it "displays the editing form with errors" do
          patch(:update, params:)

          expect(flash[:alert]).not_to be_empty
          expect(response).to have_http_status(:ok)
          expect(subject).to render_template(:edit)
          expect(response.body).to include("There was a problem saving")
        end
      end
    end
  end

  describe "PATCH soft_delete" do
    let(:component) { create(:proposal_component) }
    let(:proposal) { create(:proposal, component:) }

    it "soft deletes the proposal" do
      expect(Decidim::Commands::SoftDeleteResource).to receive(:call).with(proposal, user).and_call_original

      patch :soft_delete, params: { id: proposal.id }

      expect(response).to redirect_to(proposals_path)
      expect(flash[:notice]).to eq(I18n.t("proposals.soft_delete.success", scope: "decidim.proposals.admin"))
      expect(proposal.reload.deleted_at).not_to be_nil
    end
  end

  describe "PATCH restore" do
    let(:component) { create(:proposal_component) }
    let!(:deleted_proposal) { create(:proposal, component:, deleted_at: Time.current) }

    it "restores the deleted proposal" do
      expect(Decidim::Commands::RestoreResource).to receive(:call).with(deleted_proposal, user).and_call_original

      patch :restore, params: { id: deleted_proposal.id }

      expect(response).to redirect_to(manage_trash_proposals_path)
      expect(flash[:notice]).to eq(I18n.t("proposals.restore.success", scope: "decidim.proposals.admin"))
      expect(deleted_proposal.reload.deleted_at).to be_nil
    end
  end

  describe "GET deleted" do
    let(:component) { create(:proposal_component) }
    let!(:deleted_proposal) { create(:proposal, component:, deleted_at: Time.current) }
    let!(:active_proposal) { create(:proposal, component:) }

    it "lists only deleted proposals" do
      get :manage_trash

      expect(response).to have_http_status(:ok)
      expect(assigns(:deleted_proposals)).not_to include(active_proposal)
      expect(assigns(:deleted_proposals)).to include(deleted_proposal)
    end

    it "renders the deleted proposals template" do
      get :manage_trash

      expect(response).to render_template(:manage_trash)
    end
  end
end
