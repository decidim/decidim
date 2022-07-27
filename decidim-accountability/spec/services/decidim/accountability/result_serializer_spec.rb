# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Accountability
    describe ResultSerializer do
      subject do
        described_class.new(result)
      end

      let!(:parent) { create(:result) }
      let!(:result) { create(:result, parent:, component: parent.component) }
      let!(:category) { create(:category, participatory_space: component.participatory_space) }
      let!(:scope) { create(:scope, organization: component.participatory_space.organization) }
      let(:participatory_process) { component.participatory_space }
      let(:component) { result.component }

      let!(:proposal_component) { create(:proposal_component, participatory_space: participatory_process) }
      let(:proposals) { create_list(:proposal, 2, component: proposal_component) }

      before do
        result.update!(category:)
        result.update!(scope:)
        result.link_resources(proposals, "included_proposals")
      end

      describe "#serialize" do
        let(:serialized) { subject.serialize }

        it "serializes the id" do
          expect(serialized).to include(id: result.id)
        end

        it "serializes the category" do
          expect(serialized[:category]).to include(id: category.id)
          expect(serialized[:category]).to include(name: category.name)
        end

        it "serializes the scope" do
          expect(serialized[:scope]).to include(id: scope.id)
          expect(serialized[:scope]).to include(name: scope.name)
        end

        it "serializes the parent" do
          expect(serialized[:parent]).to include(id: result.parent.id)
        end

        it "serializes the start date" do
          expect(serialized).to include(start_date: result.start_date)
        end

        it "serializes the end date" do
          expect(serialized).to include(end_date: result.end_date)
        end

        it "serializes the status" do
          expect(serialized[:status]).to include(id: result.status.id)
          expect(serialized[:status]).to include(key: result.status.key)
          expect(serialized[:status]).to include(name: result.status.name)
        end

        it "serializes the progress" do
          expect(serialized).to include(progress: result.progress)
        end

        it "serializes the title" do
          I18n.available_locales.each do |locale|
            expect(translated(serialized[:title], locale:)).to eq(translated(result.title, locale:))
          end
        end

        it "serializes the description" do
          I18n.available_locales.each do |locale|
            expect(translated(serialized[:description], locale:)).to eq(translated(result.description, locale:))
          end
        end

        it "serializes the date of creation" do
          expect(serialized).to include(created_at: result.created_at)
        end

        it "serializes the url" do
          expect(serialized[:url]).to include("http", result.id.to_s)
        end

        it "serializes the component" do
          expect(serialized[:component]).to include(id: result.component.id)
        end

        it "serializes the proposals" do
          expect(serialized[:proposal_urls].length).to eq(2)
          expect(serialized[:proposal_urls].first).to match(%r{http.*/proposals})
        end
      end
    end
  end
end
