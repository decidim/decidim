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
        @request.env["decidim.current_organization"] = organization
      end

      describe "assemblies" do
        it "includes only published, with promoted listed first" do
          expect(controller.helpers.assemblies).to match_array([promoted, published])
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
            get :show, params: { id: unpublished_assembly.id }

            expect(response).to redirect_to("/")
          end
        end
      end
    end
  end
end
