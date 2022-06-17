# frozen_string_literal: true

require "spec_helper"

describe "Surveys component" do # rubocop:disable RSpec/DescribeClass
  subject { component }

  let(:component) { create :surveys_component }
  let(:new_component) { create :surveys_component }

  describe "before_destroy hooks" do
    context "when there are no answers" do
      before do
        create :survey, component:
      end

      it "does not raise any error" do
        expect { subject.manifest.run_hooks(:before_destroy, subject) }.not_to raise_error
      end
    end

    context "with answers" do
      before do
        survey = create :survey, component: component
        create :answer, questionnaire: survey.questionnaire
      end

      it "raises an error" do
        expect { subject.manifest.run_hooks(:before_destroy, subject) }.to raise_error(
          RuntimeError,
          "Can't destroy this component when there are survey answers"
        )
      end
    end
  end

  context "when copying component" do
    it "does not raise any error" do
      expect { subject.manifest.run_hooks(:copy, old_component: component, new_component:) }.not_to raise_error
    end

    it "create a survey component" do
      expect { subject.manifest.run_hooks(:copy, old_component: component, new_component:) }.to change { Decidim::Surveys::Survey.count }.by(1)
    end
  end
end
