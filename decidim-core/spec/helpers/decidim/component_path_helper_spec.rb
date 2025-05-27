# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ComponentPathHelper do
    let(:participatory_process) { create(:participatory_process, slug: "my-process") }

    let(:component) do
      create(:component, id: 21, participatory_space: participatory_process)
    end

    describe "main_component_path" do
      it "resolves the root path for the component" do
        expect(helper.main_component_path(component)).to eq("/en/processes/my-process/f/21/")
      end

      context "when a secondary locale is set" do
        around do |example|
          I18n.with_locale(:ca) { example.run }
        end

        it "adds the locale to the path" do
          expect(helper.main_component_path(component)).to eq("/ca/processes/my-process/f/21/")
        end
      end
    end

    describe "main_component_url" do
      it "resolves the root url for the component" do
        expect(helper.main_component_url(component)).to start_with("http://")
        expect(helper.main_component_url(component)).to include("/processes/my-process/f/21/")
      end

      context "when a secondary locale is set" do
        around do |example|
          I18n.with_locale(:ca) { example.run }
        end

        it "adds the locale to the url" do
          expect(helper.main_component_url(component)).to start_with("http://")
          expect(helper.main_component_url(component)).to include("/ca/processes/my-process/f/21/")
        end
      end
    end

    describe "manage_component_path" do
      it "resolves the admin root path for the component" do
        expect(helper.manage_component_path(component))
          .to eq("/admin/participatory_processes/my-process/components/21/manage/")
      end

      context "when a secondary locale is set" do
        around do |example|
          I18n.with_locale(:ca) { example.run }
        end

        it "adds the locale to the path" do
          expect(helper.manage_component_path(component))
            .to eq("/admin/participatory_processes/my-process/components/21/manage/")
        end
      end
    end
  end
end
