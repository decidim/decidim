# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Questionnaire templates cross-organization protection" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:other_org) { create(:organization) }

  let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
  let(:component) { create(:surveys_component, participatory_space: participatory_process) }
  let(:survey) { create(:survey, component:) }
  let(:questionnaire) { survey.questionnaire }
  let!(:template) { create(:questionnaire_template, organization:) }

  let(:headers) { { "HOST" => organization.host } }

  before do
    questionnaire.update!(questionnaire_for: survey)
    login_as user, scope: :user
  end

  describe "POST /questionnaire_templates/apply" do
    let(:path) { "/en/admin/templates/questionnaire_templates/apply" }
    let(:params) do
      {
        questionnaire_id: questionnaire.id,
        questionnaire: { questionnaire_template_id: template.id },
        url: "/en/admin/"
      }
    end

    context "with a cross-organization questionnaire" do
      let(:other_process) { create(:participatory_process, :with_steps, organization: other_org) }
      let(:other_component) { create(:surveys_component, participatory_space: other_process) }
      let(:other_survey) { create(:survey, component: other_component) }
      let(:other_questionnaire) { other_survey.questionnaire }

      it "rejects the request without mutating the questionnaire" do
        other_questionnaire.update!(questionnaire_for: other_survey)
        previous_title = other_questionnaire.title

        post(path, params: params.merge(questionnaire_id: other_questionnaire.id), headers:)

        expect(other_questionnaire.reload.title).to eq(previous_title)
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to("/en/admin/")
      end
    end

    context "with own questionnaire and template" do
      it "applies the template" do
        expect { post(path, params:, headers:) }
          .to(change { questionnaire.reload.title })

        expect(response).to have_http_status(:found)
      end
    end
  end

  describe "POST /questionnaire_templates/skip" do
    let(:path) { "/en/admin/templates/questionnaire_templates/skip" }
    let(:params) { { questionnaire_id: questionnaire.id, url: "/en/admin/" } }

    context "with a cross-organization questionnaire" do
      let(:other_process) { create(:participatory_process, :with_steps, organization: other_org) }
      let(:other_component) { create(:surveys_component, participatory_space: other_process) }
      let(:other_survey) { create(:survey, component: other_component) }
      let(:other_questionnaire) { other_survey.questionnaire }

      it "rejects the request without touching the questionnaire" do
        other_questionnaire.update!(questionnaire_for: other_survey)
        previous_updated_at = other_questionnaire.reload.updated_at

        post(path, params: params.merge(questionnaire_id: other_questionnaire.id), headers:)

        expect(other_questionnaire.reload.updated_at).to eq(previous_updated_at)
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to("/en/admin/")
      end
    end

    context "with own questionnaire" do
      it "touches the questionnaire" do
        expect { post(path, params:, headers:) }
          .to(change { questionnaire.reload.updated_at })

        expect(response).to have_http_status(:found)
      end
    end
  end
end
