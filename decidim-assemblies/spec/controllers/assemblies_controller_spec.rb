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

      describe "published_assemblies" do
        context "when there are no published assemblies" do
          before do
            published.unpublish!
            promoted.unpublish!
          end

          it "redirects to 404" do
            expect { get :index }.to raise_error(ActionController::RoutingError)
          end
        end
      end

      describe "GET assemblies in json format" do
        let!(:first_level) { create(:assembly, :published, :with_parent, parent: published, organization: organization) }
        let!(:second_level_2) { create(:assembly, :published, :with_parent, parent: first_level, weight: 2, organization: organization) }
        let!(:second_level_1) { create(:assembly, :published, :with_parent, parent: first_level, weight: 1, organization: organization) }
        let!(:third_level) { create(:assembly, :published, :with_parent, parent: second_level_1, organization: organization) }

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
                    children: [
                      {
                        name: translated(second_level_1.title)
                      },
                      {
                        name: translated(second_level_2.title)
                      }
                    ]
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

      describe "parent_assemblies" do
        let!(:child_assembly) { create(:assembly, parent: published, organization: organization) }

        it "includes only parent assemblies, with promoted listed first" do
          expect(controller.helpers.parent_assemblies.first).to eq(promoted)
          expect(controller.helpers.parent_assemblies.second).to eq(published)
        end
      end

      describe "GET show" do
        context "when the assembly is unpublished" do
          it "redirects to sign in path" do
            get :show, params: { slug: unpublished_assembly.slug }

            expect(response).to redirect_to("/users/sign_in")
          end

          context "with signed in user" do
            let!(:user) { create(:user, :confirmed, organization: organization) }

            before do
              sign_in user, scope: :user
            end

            it "redirects to root path" do
              get :show, params: { slug: unpublished_assembly.slug }

              expect(response).to redirect_to("/")
            end
          end
        end
      end
    end
  end
end
