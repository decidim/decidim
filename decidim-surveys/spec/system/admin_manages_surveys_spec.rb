# frozen_string_literal: true

require "spec_helper"

describe "Admin manages surveys", type: :system do
  let(:manifest_name) { "surveys" }
  let!(:questionnaire) { create(:questionnaire) }
  let!(:survey) { create :survey, component: component, questionnaire: questionnaire }

  include_context "when managing a component as an admin"

  it_behaves_like "manage questionnaires"
  it_behaves_like "export survey user answers"
  it_behaves_like "manage announcements"

  def questionnaire_edit_path
    manage_component_path(component)
  end

  def questionnaire_public_path
    main_component_path(component)
  end
end
