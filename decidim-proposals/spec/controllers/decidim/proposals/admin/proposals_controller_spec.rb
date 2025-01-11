# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/softdeleteable_components_examples"

describe Decidim::Proposals::Admin::ProposalsController do
  let(:component) { create(:proposal_component) }
  let(:proposal) { create(:proposal, component:) }
  let(:current_user) { create(:user, :confirmed, :admin, organization: component.organization) }

  before do
    request.env["decidim.current_organization"] = component.organization
    request.env["decidim.current_participatory_space"] = component.participatory_space
    request.env["decidim.current_component"] = component
    sign_in current_user
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

  it_behaves_like "a soft-deletable resource",
                  resource_name: :proposal,
                  resource_path: :proposals_path,
                  trash_path: :manage_trash_proposals_path
end
