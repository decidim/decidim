# frozen_string_literal: true

require "spec_helper"

describe "Demographics" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization:) }
  let!(:questionnaire_for) { create(:demographic, organization:, collect_data: true) }
  let!(:questionnaire) { create(:questionnaire, questionnaire_for:) }

  before do
    host! organization.host
    login_as user, scope: :user
  end

  describe "DELETE destroy" do
    context "when the data cannot be deleted" do
      before do
        stub_command_broadcast(Decidim::Demographics::DeleteDemographicData, :invalid)
      end

      it "shows the alert on the demographics page" do
        delete(demographics_engine.demographics_path)

        expect(response).to redirect_to(demographics_engine.demographics_path)
        follow_redirect!

        expect(response.body).to include(I18n.t("destroy.error", scope: "decidim.demographics"))
      end
    end
  end
end
