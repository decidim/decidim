# frozen_string_literal: true

require "spec_helper"

# users of this test should declare the `subject` variable.
shared_examples "with likable permissions can perform actions related to likable" do
  let(:action_subject) { :like }
  let(:resource) { create(:dummy_resource, component:) }
  before do
    context[:current_settings] = double(current_settings)
    context[:resource] = resource
  end

  describe "liking" do
    describe "when liking" do
      let(:action_name) { :create }

      context "when likes are disabled" do
        let(:current_settings) do
          {
            endorsements_enabled: false,
            endorsements_blocked: false
          }
        end

        it { is_expected.to eq false }
      end

      context "when likes are blocked" do
        let(:current_settings) do
          {
            endorsements_enabled: true,
            endorsements_blocked: true
          }
        end

        it { is_expected.to eq false }
      end

      context "when user is authorized" do
        let(:current_settings) do
          {
            endorsements_enabled: true,
            endorsements_blocked: false
          }
        end

        it { is_expected.to eq true }
      end
    end
  end

  describe "unliking" do
    let(:action_name) { :unlike }

    context "when likes are disabled" do
      let(:current_settings) do
        {
          endorsements_enabled: false,
          endorsements_blocked: false
        }
      end

      it { is_expected.to eq false }
    end

    context "when likes are blocked" do
      let(:current_settings) do
        {
          endorsements_enabled: true,
          endorsements_blocked: true
        }
      end

      it { is_expected.to eq false }
    end

    context "when user is authorized" do
      let(:current_settings) do
        {
          endorsements_enabled: true,
          endorsements_blocked: false
        }
      end

      it { is_expected.to eq true }
    end
  end
end
