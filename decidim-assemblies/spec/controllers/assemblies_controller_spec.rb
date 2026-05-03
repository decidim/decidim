# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Assemblies
    describe AssembliesController do
      routes { Decidim::Assemblies::Engine.routes }

      let(:organization) { create(:organization) }

      let!(:unpublished_assembly) do
        create(
          :assembly,
          :unpublished,
          organization:
        )
      end

      let!(:promoted) do
        create(
          :assembly,
          :published,
          :promoted,
          weight: 2,
          organization:
        )
      end

      let!(:published) do
        create(
          :assembly,
          :published,
          weight: 3,
          organization:
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
            expect { get :index, params: { locale: I18n.locale } }.to raise_error(ActionController::RoutingError)
          end
        end

        context "when there are published assemblies" do
          let!(:another_published) do
            create(
              :assembly,
              :published,
              weight: 1,
              organization:
            )
          end

          it "orders assemblies by weight" do
            expect(controller.helpers.collection).to eq([another_published, promoted, published])
          end
        end
      end

      describe "GET assemblies in json format" do
        let!(:first_level) { create(:assembly, :published, :with_parent, parent: published, organization:) }
        let!(:second_level) { create(:assembly, :published, :with_parent, parent: first_level, organization:) }
        let!(:third_level) { create(:assembly, :published, :with_parent, parent: second_level, organization:) }

        let(:parsed_response) { JSON.parse(response.body, symbolize_names: true) }

        it "includes only published assemblies with their children (two levels)" do
          get :index, params: { locale: I18n.locale }, format: :json
          expect(parsed_response).to contain_exactly({
                                                       name: translated(promoted.title),
                                                       children: []
                                                     }, {
                                                       name: translated(published.title),
                                                       children: [
                                                         {
                                                           name: translated(first_level.title),
                                                           children: [{ name: translated(second_level.title) }]
                                                         }
                                                       ]
                                                     })
        end
      end

      describe "promoted_assemblies" do
        it "includes only promoted" do
          expect(controller.helpers.promoted_assemblies).to contain_exactly(promoted)
        end
      end

      describe "parent_assemblies" do
        let!(:child_assembly) { create(:assembly, parent: published, organization:) }

        it "includes only parent assemblies, with promoted listed first" do
          expect(controller.helpers.parent_assemblies.first).to eq(promoted)
          expect(controller.helpers.parent_assemblies.second).to eq(published)
        end
      end

      describe "GET show" do
        context "when the assembly is unpublished" do
          it "redirects to sign in path" do
            get :show, params: { slug: unpublished_assembly.slug, locale: I18n.locale }

            expect(response).to redirect_to("/users/sign_in")
          end

          context "with signed in user" do
            let!(:user) { create(:user, :confirmed, organization:) }

            before do
              sign_in user, scope: :user
            end

            it "redirects to root path" do
              get :show, params: { slug: unpublished_assembly.slug, locale: I18n.locale }

              expect(response).to redirect_to("/")
            end
          end
        end
      end
    end
  end
end
