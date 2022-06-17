# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Admin::ElectionsController, type: :controller do
  routes { Decidim::Elections::AdminEngine.routes }

  let(:user) { create(:user, :confirmed, :admin, organization: component.organization) }

  before do
    request.env["decidim.current_organization"] = component.organization
    request.env["decidim.current_participatory_space"] = component.participatory_space
    request.env["decidim.current_component"] = component
    sign_in user
  end

  describe "PATCH update" do
    let(:datetime_format) { I18n.t("time.formats.decidim_short") }
    let(:component) { create(:elections_component) }
    let(:election) { create(:election, component:) }
    let(:election_title) { election.title }
    let(:election_params) do
      {
        title: election_title,
        description: election.description,
        start_time: election.start_time.strftime(datetime_format),
        end_time: election.end_time.strftime(datetime_format),
        attachment: {
          title: "",
          file: nil
        },
        photos: election.photos.map { |a| a.id.to_s }
      }
    end
    let(:params) do
      {
        id: election.id,
        election: election_params
      }
    end

    it "updates the election" do
      allow(controller).to receive(:elections_path).and_return("/elections")

      patch :update, params: params

      expect(flash[:notice]).not_to be_empty
      expect(response).to have_http_status(:found)
    end

    context "when the existing election has photos and there are other errors on the form" do
      include_context "with controller rendering the view" do
        let(:election_title) { { en: "" } }
        let(:election) { create(:election, :with_photos, component:) }

        it "displays the editing form with errors" do
          patch :update, params: params

          expect(flash[:alert]).not_to be_empty
          expect(response).to have_http_status(:ok)
          expect(subject).to render_template(:edit)
          expect(response.body).to include("There was a problem updating this election")
        end
      end
    end
  end
end
