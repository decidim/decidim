# frozen_string_literal: true

require "spec_helper"

describe "Surveys component" do # rubocop:disable RSpec/DescribeClass
  subject { component }

  let(:component) { create(:surveys_component) }
  let(:new_component) { create(:surveys_component) }

  context "when copying component" do
    it "does not raise any error" do
      expect { subject.manifest.run_hooks(:copy, old_component: component, new_component:) }.not_to raise_error
    end
  end

  describe "component exports" do
    subject do
      component
        .manifest
        .export_manifests
        .find { |manifest| manifest.name == :survey_user_responses }
        &.collection
        &.call(component, user, survey2.id)
    end

    let(:component) { create(:surveys_component) }
    let(:survey) { create(:survey, component:) }
    let(:survey2) { create(:survey, component:) }
    let!(:survey_responses) { create_list(:response, 3, questionnaire: survey.questionnaire) }
    let!(:other_survey_responses) { create_list(:response, 4, questionnaire: survey2.questionnaire) }
    let(:organization) { component.participatory_space.organization }

    context "when the user is an admin" do
      let!(:user) { create(:user, admin: true, organization:) }

      it "exports responses only for the requested survey" do
        expect(subject.count).to eq(4)
        expect(subject.flatten.map(&:id)).to match_array(other_survey_responses.map(&:id))
      end
    end
  end
end
