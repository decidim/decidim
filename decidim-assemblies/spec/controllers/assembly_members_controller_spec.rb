# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Assemblies
    describe AssemblyMembersController, type: :controller do
      routes { Decidim::Assemblies::Engine.routes }

      let(:organization) { create(:organization) }

      let!(:assembly) do
        create(
          :assembly,
          :published,
          organization:
        )
      end

      before do
        request.env["decidim.current_organization"] = organization
      end

      describe "GET index" do
        context "when assembly has no members" do
          it "redirects to 404" do
            expect { get :index, params: { assembly_slug: assembly.slug } }
              .to raise_error(ActionController::RoutingError)
          end
        end

        context "when assembly has members" do
          let!(:member1) { create(:assembly_member, assembly:) }
          let!(:member2) { create(:assembly_member, assembly:) }
          let!(:non_member) { create(:assembly_member) }

          context "when user has permissions" do
            it "displays list of members" do
              get :index, params: { assembly_slug: assembly.slug }

              expect(controller.helpers.collection).to match_array([member1, member2])
            end
          end

          context "when user does not have permissions" do
            before do
              allow(controller).to receive(:current_user_can_visit_space?).and_return(false)
            end

            it "redirects to assembly path" do
              get :index, params: { assembly_slug: assembly.slug }

              expect(response).to redirect_to(assembly_path(assembly))
            end
          end
        end
      end
    end
  end
end
