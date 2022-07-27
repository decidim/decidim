# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe ImportsHelper do
      describe "#import_dropdown" do
        subject do
          Nokogiri::HTML(helper.import_dropdown(component))
        end

        let!(:component) { create(:component, manifest_name: "dummy") }

        it "creates an import dropdown" do
          expect(subject.css("li").length).to eq(1)
        end

        it "creates a link" do
          link = subject.css("li.imports--dummies").css("a")[0].attributes["href"]
          expect(link.value).to eq("/admin/participatory_processes/#{component.participatory_space.slug}/components/#{component.id}/imports/new?name=dummies")
        end
      end

      describe "#mime_types" do
        it "returns the expected mime types" do
          expect(helper.mime_types).to eq(
            csv: "CSV",
            json: "JSON",
            xlsx: "Excel (.xlsx)"
          )
        end
      end

      describe "#admin_imports_path" do
        let(:component) { create(:dummy_component) }

        it "returns the correct link" do
          expect(helper.admin_imports_path(component, name: "dummies")).to eq("/admin/participatory_processes/#{component.participatory_space.slug}/components/#{component.id}/imports/new?name=dummies")
        end
      end

      describe "#admin_imports_example_path" do
        let(:component) { create(:dummy_component) }

        it "returns the correct link" do
          expect(helper.admin_imports_example_path(component, name: "dummies", format: "json")).to eq("/admin/participatory_processes/#{component.participatory_space.slug}/components/#{component.id}/imports/example.json?name=dummies")
        end
      end

      describe "#user_groups" do
        before do
          allow(helper).to receive(:current_user).and_return(user)
        end

        let(:organization) { create :organization, available_locales: [:en] }
        let(:user) { create :user, organization: }
        let(:user_group) { create :user_group, :confirmed, :verified, organization: }
        let!(:membership) { create(:user_group_membership, user:, user_group:) }

        it "return users user groups" do
          expect(helper.user_groups.count).to eq(1)
        end
      end
    end
  end
end
