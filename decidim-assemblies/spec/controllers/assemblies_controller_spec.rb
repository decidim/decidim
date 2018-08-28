# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Assemblies
    describe AssembliesController, type: :controller do
      routes { Decidim::Assemblies::Engine.routes }

      let(:organization) { create(:organization) }

      let!(:unpublished_assembly) do
        create(
          :assembly,
          :unpublished,
          organization: organization
        )
      end

      let!(:published) do
        create(
          :assembly,
          :published,
          organization: organization
        )
      end

      let!(:promoted) do
        create(
          :assembly,
          :published,
          :promoted,
          organization: organization
        )
      end

      before do
        request.env["decidim.current_organization"] = organization
      end

      describe "assemblies" do
        it "includes only published, with promoted listed first" do
          expect(controller.helpers.assemblies).to match_array([promoted, published])
        end
      end

      describe "GET assemblies in json format" do
        let!(:first_level) { create(:assembly, :published, :with_parent, parent: published, organization: organization) }
        let!(:second_level) { create(:assembly, :published, :with_parent, parent: first_level, organization: organization) }
        let!(:third_level) { create(:assembly, :published, :with_parent, parent: second_level, organization: organization) }

        let(:parsed_response) { JSON.parse(response.body, symbolize_names: true) }

        it "includes only published assemblies with their children (two levels)" do
          get :index, format: :json
          expect(parsed_response).to match_array(
            [
              {
                name: translated(promoted.title),
                children: []
              },
              {
                name: translated(published.title),
                children: [
                  {
                    name: translated(first_level.title),
                    children: [{ name: translated(second_level.title) }]
                  }
                ]
              }
            ]
          )
        end
      end

      describe "promoted_assemblies" do
        it "includes only promoted" do
          expect(controller.helpers.promoted_assemblies).to contain_exactly(promoted)
        end
      end

      describe "GET show" do
        context "when the assembly is unpublished" do
          it "redirects to root path" do
            get :show, params: { slug: unpublished_assembly.slug }

            expect(response).to redirect_to("/")
          end
        end
      end
    end
  end
end
