# frozen_string_literal: true

require "spec_helper"

describe "Surveys component" do # rubocop:disable RSpec/DescribeClass
  subject { component }

  let(:component) { create(:surveys_component) }
  let(:new_component) { create(:surveys_component) }

  describe "before_destroy hooks" do
    context "when there are no responses" do
      before do
        create(:survey, component:)
      end

      it "does not raise any error" do
        expect { subject.manifest.run_hooks(:before_destroy, subject) }.not_to raise_error
      end
    end

    context "with responses" do
      before do
        survey = create(:survey, component:)
        create(:response, questionnaire: survey.questionnaire)
      end

      it "raises an error" do
        expect { subject.manifest.run_hooks(:before_destroy, subject) }.to raise_error(
          RuntimeError,
          "Cannot destroy this component when there are survey responses"
        )
      end
    end
  end

  context "when copying component" do
    it "does not raise any error" do
      expect { subject.manifest.run_hooks(:copy, old_component: component, new_component:) }.not_to raise_error
    end
  end
end
