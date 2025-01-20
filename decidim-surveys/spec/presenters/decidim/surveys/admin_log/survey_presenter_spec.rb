# frozen_string_literal: true

require "spec_helper"

describe Decidim::Surveys::AdminLog::SurveyPresenter, type: :helper do
  include_examples "present admin log entry" do
    let(:participatory_space) { create(:participatory_process, organization:) }
    let(:component) { create(:surveys_component, participatory_space:) }
    let(:admin_log_resource) { create(:survey, component:) }
    let(:action) { "update" }
  end
end
