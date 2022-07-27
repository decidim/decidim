# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Assemblies::AdminLog::AssembliesSettingPresenter, type: :helper do
    subject { described_class.new(action_log, helper) }

    let(:action_log) do
      create(
        :action_log,
        action:
      )
    end
    let(:action) { :update }

    before do
      helper.extend(Decidim::ApplicationHelper)
      helper.extend(Decidim::TranslationsHelper)
    end

    describe "#present" do
      context "when the setting is updated" do
        it "shows the settings has been updated" do
          expect(subject.present).to include("updated the assemblies settings")
        end
      end
    end
  end
end
