# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe EngineRouter do
    let(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, slug: "my-process", organization:) }
    let(:component) { create(:component, id: 21, participatory_space: participatory_process) }

    describe ".admin_proxy" do
      context "when the target is a component" do
        subject(:proxy) { described_class.admin_proxy(component) }

        it "resolves the admin root path with the default locale" do
          expect(proxy.root_path)
            .to eq("/en/admin/participatory_processes/my-process/components/21/manage/")
        end

        context "when a secondary locale is set" do
          around do |example|
            I18n.with_locale(:ca) { example.run }
          end

          it "resolves the admin root path with the current locale" do
            expect(proxy.root_path)
              .to eq("/ca/admin/participatory_processes/my-process/components/21/manage/")
          end
        end
      end

      context "when the target is a participatory space" do
        subject(:proxy) { described_class.admin_proxy(participatory_process) }

        it "resolves admin paths with the default locale" do
          expect(proxy.components_path)
            .to eq("/en/admin/participatory_processes/my-process/components")
        end

        context "when a secondary locale is set" do
          around do |example|
            I18n.with_locale(:ca) { example.run }
          end

          it "resolves admin paths with the current locale" do
            expect(proxy.components_path)
              .to eq("/ca/admin/participatory_processes/my-process/components")
          end
        end
      end
    end

    describe ".main_proxy" do
      context "when the target is a component" do
        subject(:proxy) { described_class.main_proxy(component) }

        it "resolves the frontend root path with the default locale" do
          expect(proxy.root_path)
            .to eq("/en/processes/my-process/f/21/")
        end

        context "when a secondary locale is set" do
          around do |example|
            I18n.with_locale(:ca) { example.run }
          end

          it "resolves the frontend root path with the current locale" do
            expect(proxy.root_path)
              .to eq("/ca/processes/my-process/f/21/")
          end
        end
      end

      context "when the target is a participatory space" do
        subject(:proxy) { described_class.main_proxy(participatory_process) }

        it "resolves frontend paths with the default locale" do
          expect(proxy.participatory_process_path(slug: "my-process"))
            .to include("/en/processes/my-process")
        end

        context "when a secondary locale is set" do
          around do |example|
            I18n.with_locale(:ca) { example.run }
          end

          it "resolves frontend paths with the current locale" do
            expect(proxy.participatory_process_path(slug: "my-process"))
              .to include("/ca/processes/my-process")
          end
        end
      end
    end
  end
end
