# frozen_string_literal: true

require "spec_helper"

describe "Surveys component" do # rubocop:disable RSpec/DescribeClass
  subject { component }

  let(:component) { create(:surveys_component) }
  let(:new_component) { create(:surveys_component) }

  describe "before_destroy hooks" do
    context "when there are no answers" do
      before do
        create(:survey, component:)
      end

      it "does not raise any error" do
        expect { subject.manifest.run_hooks(:before_destroy, subject) }.not_to raise_error
      end
    end

    context "with answers" do
      before do
        survey = create(:survey, component:)
        create(:answer, questionnaire: survey.questionnaire)
      end

      it "raises an error" do
        expect { subject.manifest.run_hooks(:before_destroy, subject) }.to raise_error(
          RuntimeError,
          "Cannot destroy this component when there are survey answers"
        )
      end
    end
  end

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
        .find { |manifest| manifest.name == :survey_user_answers }
        &.collection
        &.call(component, user, survey2.id)
    end

    let(:component) { create(:surveys_component) }
    let!(:survey) { create(:survey, component:) }
    let!(:survey2) { create(:survey, component:) }
    let!(:survey_answers) { create_list(:answer, 3, questionnaire: survey.questionnaire) }
    let!(:other_survey_answers) { create_list(:answer, 4, questionnaire: survey2.questionnaire) }
    let(:organization) { component.participatory_space.organization }

    context "when the user is an admin" do
      let!(:user) { create(:user, admin: true, organization:) }

      it "exports responses only for the requested survey" do
        expect(subject.count).to eq(4)
        expect(subject.flatten.map(&:id)).to match_array(other_survey_answers.map(&:id))
      end
    end
  end
end
