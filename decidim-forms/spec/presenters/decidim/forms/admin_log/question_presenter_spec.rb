# frozen_string_literal: true

require "spec_helper"

describe Decidim::Forms::AdminLog::QuestionPresenter, type: :helper do
  include_examples "present admin log entry" do
    let(:participatory_space) { create(:participatory_process, organization:) }
    let(:questionnaire) { create(:questionnaire) }
    let(:manifest_name) { "surveys" }
    let(:manifest) { Decidim.find_component_manifest(manifest_name) }
    let!(:component) { create(:component, manifest:, participatory_space:, published_at: nil) }
    let!(:survey) { create(:survey, component:, questionnaire:) }

    let(:admin_log_resource) { create(:questionnaire_question, questionnaire:) }
    let(:action) { "update" }
  end
end
