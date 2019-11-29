# frozen_string_literal: true

require "spec_helper"

# users of this test should delare the `subject` variable.
shared_examples "with endorsable permissions can perform actions related to endorsable" do |action_subject|
  describe "endorsing" do
    let(:action) do
      { scope: :public, action: :endorse, subject: action_subject }
    end

    context "when endorsements are disabled" do
      let(:extra_settings) do
        {
          endorsements_enabled?: false,
          endorsements_blocked?: false
        }
      end

      it { is_expected.to eq false }
    end

    context "when endorsements are blocked" do
      let(:extra_settings) do
        {
          endorsements_enabled?: true,
          endorsements_blocked?: true
        }
      end

      it { is_expected.to eq false }
    end

    context "when user is authorized" do
      let(:extra_settings) do
        {
          endorsements_enabled?: true,
          endorsements_blocked?: false
        }
      end

      it { is_expected.to eq true }
    end
  end

  describe "unendorsing" do
    let(:action) do
      { scope: :public, action: :unendorse, subject: action_subject }
    end

    context "when endorsements are disabled" do
      let(:extra_settings) do
        {
          endorsements_enabled?: false
        }
      end

      it { is_expected.to eq false }
    end

    context "when user is authorized" do
      let(:extra_settings) do
        {
          endorsements_enabled?: true
        }
      end

      it { is_expected.to eq true }
    end
  end
end
