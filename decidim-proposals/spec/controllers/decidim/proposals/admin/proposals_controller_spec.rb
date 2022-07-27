# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::Admin::ProposalsController, type: :controller do
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

      patch :update, params: params

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
          patch :update, params: params

          expect(flash[:alert]).not_to be_empty
          expect(response).to have_http_status(:ok)
          expect(subject).to render_template(:edit)
          expect(response.body).to include("There was a problem saving")
        end
      end
    end
  end
end
