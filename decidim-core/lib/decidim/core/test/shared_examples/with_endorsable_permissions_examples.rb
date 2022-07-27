# frozen_string_literal: true

require "spec_helper"

# users of this test should delare the `subject` variable.
shared_examples "with endorsable permissions can perform actions related to endorsable" do
  let(:action_subject) { :endorsement }
  let(:resource) { create :dummy_resource, component: }
  before do
    context[:current_settings] = double(current_settings)
    context[:resource] = resource
  end

  describe "endorsing" do
    describe "when endorsing" do
      let(:action_name) { :create }

      context "when endorsements are disabled" do
        let(:current_settings) do
          {
            endorsements_enabled: false,
            endorsements_blocked: false
          }
        end

        it { is_expected.to eq false }
      end

      context "when endorsements are blocked" do
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

  describe "unendorsing" do
    let(:action_name) { :unendorse }

    context "when endorsements are disabled" do
      let(:current_settings) do
        {
          endorsements_enabled: false,
          endorsements_blocked: false
        }
      end

      it { is_expected.to eq false }
    end

    context "when endorsements are blocked" do
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
