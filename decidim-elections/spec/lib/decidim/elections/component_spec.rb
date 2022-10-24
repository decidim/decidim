# frozen_string_literal: true

require "spec_helper"

describe "Elections component" do # rubocop:disable RSpec/DescribeClass
  subject { component }

  let(:component) { create :elections_component }

  describe "before_destroy hooks" do
    context "when there are no elections" do
      it "does not raise any error" do
        expect { subject.manifest.run_hooks(:before_destroy, subject) }.not_to raise_error
      end
    end

    context "with elections" do
      before do
        create :election, component:
      end

      it "raises an error" do
        expect { subject.manifest.run_hooks(:before_destroy, subject) }.to raise_error(
          StandardError,
          "Can't remove this component"
        )
      end
    end
  end
end
