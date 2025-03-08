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
      let!(:taxonomies) { create_list(:taxonomy, 2, :with_parent, organization: component.organization) }
      let(:participatory_process) { component.participatory_space }
      let(:component) { result.component }

      let!(:proposal_component) { create(:proposal_component, participatory_space: participatory_process) }
      let(:proposals) { create_list(:proposal, 2, component: proposal_component) }
      let(:serialized_taxonomies) do
        { ids: taxonomies.pluck(:id) }.merge(taxonomies.to_h { |t| [t.id, t.name] })
      end

      before do
        result.update!(taxonomies:)
        result.link_resources(proposals, "included_proposals")
      end

      # Internal field for admins. Test is implemented to make sure the external_id is not published
      describe "external_id" do
        it "is not published" do
          expect(subject.serialize).not_to have_key(:external_id)
        end
      end

      describe "#serialize" do
        let(:serialized) { subject.serialize }

        it "serializes the id" do
          expect(serialized).to include(id: result.id)
        end

        it "serializes the taxonomies" do
          expect(serialized[:taxonomies]).to eq(serialized_taxonomies)
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

        it "serializes the reference" do
          expect(serialized).to include(reference: result.reference)
        end

        it "serializes the updated date" do
          expect(serialized).to include(updated_at: result.updated_at)
        end

        it "serializes the children count" do
          expect(serialized).to include(children_count: result.children_count)
        end

        it "serializes the comments count" do
          expect(serialized).to include(comments_count: result.comments_count)
        end

        it "serializes the address" do
          expect(serialized).to include(address: result.address)
        end

        it "serializes the latitude" do
          expect(serialized).to include(latitude: result.latitude)
        end

        it "serializes the longitude" do
          expect(serialized).to include(longitude: result.longitude)
        end
      end
    end
  end
end
