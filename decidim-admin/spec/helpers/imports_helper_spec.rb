# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe ImportsHelper do
      describe "#render" do
        subject do
          Nokogiri::HTML(helper.import_dropdown(component))
        end

        let!(:component) { create(:component, manifest_name: "dummy") }

        it "creates an import dropdown" do
          expect(subject.css("li").length).to eq(1)
        end

        it "creates a link" do
          link = subject.css("li.imports--dummy").css("a")[0].attributes["href"]
          expect(link.value).to eq("/admin/participatory_processes/#{component.participatory_space.slug}/components/#{component.id}/imports/new")
        end
      end

      describe "#mime_types" do
        before do
          allow(helper).to receive(:t).with(
            "decidim.admin.imports.new.accepted_mime_types.json"
          ).and_return("JSON")
          allow(helper).to receive(:t).with(
            "decidim.admin.imports.new.accepted_mime_types.csv"
          ).and_return("CSV")
          allow(helper).to receive(:t).with(
            "decidim.admin.imports.new.accepted_mime_types.xls"
          ).and_return("XLS")
        end

        it "returns the expected mime types" do
          expect(helper.mime_types).to eq("JSON, CSV, XLS")
        end
      end

      describe "#user_groups" do
        before do
          allow(helper).to receive(:current_user).and_return(user)
        end

        let(:organization) { create :organization, available_locales: [:en] }
        let(:user) { create :user, organization: organization }
        let(:user_group) { create :user_group, :confirmed, :verified, organization: organization }
        let!(:membership) { create(:user_group_membership, user: user, user_group: user_group) }

        it "return users user groups" do
          expect(helper.user_groups.count).to eq(1)
        end
      end
    end
  end
end
