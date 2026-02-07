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
end
