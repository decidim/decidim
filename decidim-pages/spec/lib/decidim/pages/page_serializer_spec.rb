# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Pages
    describe PageSerializer do
      subject do
        described_class.new(page)
      end

      let!(:page) { create(:page, component:) }
      let(:organization) { create(:organization) }
      let(:participatory_space) { create(:participatory_process, organization:) }
      let(:component) { create(:page_component, participatory_space:) }

      describe "#serialize" do
        let(:serialized) { subject.serialize }

        it "serializes the id" do
          expect(serialized).to include(id: page.id)
        end

        it "serializes the title" do
          expect(serialized).to include(title: page.title)
        end

        it "serializes the body" do
          expect(serialized).to include(body: page.body)
        end

        it "serializes the participatory space" do
          expect(serialized[:participatory_space]).to include(id: participatory_space.id)
          expect(serialized[:participatory_space][:url]).to include("http", participatory_space.slug)
        end

        it "serializes the component" do
          expect(serialized[:component]).to include(id: page.component.id)
        end

        it "serializes the url" do
          expect(serialized[:url]).to include("http", page.id.to_s)
        end
      end
    end
  end
end
