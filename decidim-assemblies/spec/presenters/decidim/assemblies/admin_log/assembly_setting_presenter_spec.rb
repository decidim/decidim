# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe Decidim::Assemblies::AdminLog::AssembliesSettingPresenter, type: :helper do
    subject(:assemblies_setting) { described_class.new(assemblies_setting) }

    let(:organization) { create :organization }
    let(:value) { assemblies_setting.id }
    let(:enable_organization_chart) { assemblies_setting.enable_organization_chart }

    describe "update" do
      subject { enable_organization_chart }

      context "when setting is updated" do
        it { is_expected.to eq true }
      end
    end
  end
end
