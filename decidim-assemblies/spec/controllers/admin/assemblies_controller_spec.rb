# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/softdeleteable_components_examples"

module Decidim
  module Assemblies
    module Admin
      describe AssembliesController do
        routes { Decidim::Assemblies::AdminEngine.routes }

        let(:organization) { create(:organization) }
        let(:current_user) { create(:user, :confirmed, :admin, organization:) }
        let!(:assembly) do
          create(
            :assembly,
            :published,
            organization:
          )
        end

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.current_assembly"] = assembly
          sign_in current_user
        end

        describe "GET index" do
          render_views

          def count_queries
            queries = []
            subscriber = ActiveSupport::Notifications.subscribe("sql.active_record") do |_, _, _, _, payload|
              next if payload[:cached] || payload[:name] == "SCHEMA"

              queries << payload[:sql]
            end

            yield

            queries
          ensure
            ActiveSupport::Notifications.unsubscribe(subscriber)
          end

          it "does not query each assembly's ancestors or children" do
            create_list(:assembly, 5, organization:).each do |parent|
              create(:assembly, organization:, parent:)
            end

            queries = count_queries { get :index }

            expect(response).to have_http_status(:ok)
            expect(queries.grep(/parents_path @>/)).to be_empty
            expect(queries.select { |sql| sql.include?("COUNT(*)") && sql.include?('"decidim_assemblies"."parent_id" =') }).to be_empty
          end

          it "does not run additional queries per assembly for org admins" do
            create_list(:assembly, 2, organization:)
            get :index
            expect(response).to have_http_status(:ok)

            few_queries = count_queries { get :index }
            expect(response).to have_http_status(:ok)

            create_list(:assembly, 4, organization:)
            many_queries = count_queries { get :index }
            expect(response).to have_http_status(:ok)

            expect(many_queries.size).to eq(few_queries.size)
          end

          it "does not look up the current assembly or run additional queries per child on AJAX expansion" do
            parent = create(:assembly, :published, organization:)
            create_list(:assembly, 2, :published, organization:, parent:)

            get :index, params: { q: { parent_id_eq: parent.id } }, format: :js, xhr: true
            expect(response).to have_http_status(:ok)

            few_queries = count_queries do
              get :index, params: { q: { parent_id_eq: parent.id } }, format: :js, xhr: true
            end
            expect(response).to have_http_status(:ok)

            create_list(:assembly, 6, :published, organization:, parent:)

            many_queries = count_queries do
              get :index, params: { q: { parent_id_eq: parent.id } }, format: :js, xhr: true
            end
            expect(response).to have_http_status(:ok)

            current_assembly_queries = many_queries.select { |sql| sql.include?('"decidim_assemblies"."slug"') }
            manageable_assemblies_queries = many_queries.select do |sql|
              sql.include?("SELECT 1 AS one") && sql.include?('"decidim_assemblies"."decidim_organization_id"')
            end

            expect(current_assembly_queries.size).to be <= 1
            expect(manageable_assemblies_queries.size).to be <= 1
            expect(many_queries.size).to eq(few_queries.size)
          end

          context "when the assembly has children" do
            let!(:parent_assembly) { create(:assembly, :published, organization:) }
            let!(:child_assembly) { create(:assembly, :published, organization:, parent: parent_assembly) }

            it "shows the expand arrow" do
              get :index

              row = response.parsed_body.at_css("tr[data-assembly-id='#{parent_assembly.id}']")

              expect(row.at_css("a[data-arrow-down]")).to be_present
            end

            it "does not show the expand arrow when the only child is soft deleted" do
              child_assembly.destroy!

              get :index

              row = response.parsed_body.at_css("tr[data-assembly-id='#{parent_assembly.id}']")

              expect(row.at_css("a[data-arrow-down]")).to be_nil
            end
          end
        end

        describe "#assembly_depth" do
          subject { controller.send(:assembly_depth, tested_assembly) }

          context "when the assembly is a root assembly" do
            let(:tested_assembly) { create(:assembly, organization:) }

            it { is_expected.to eq(0) }
          end

          context "when the assembly has one ancestor" do
            let(:parent) { create(:assembly, organization:) }
            let(:tested_assembly) { create(:assembly, organization:, parent:) }

            it { is_expected.to eq(1) }
          end

          context "when the assembly has multiple ancestors" do
            let(:grandparent) { create(:assembly, organization:) }
            let(:parent) { create(:assembly, organization:, parent: grandparent) }
            let(:tested_assembly) { create(:assembly, organization:, parent:) }

            it { is_expected.to eq(2) }
          end

          context "when the assembly has no parents_path" do
            let(:tested_assembly) { instance_double(Decidim::Assembly, parents_path: nil) }

            it { is_expected.to eq(0) }
          end
        end

        describe "PATCH update" do
          let(:assembly_params) do
            {
              title: assembly.title,
              subtitle: assembly.subtitle,
              description: assembly.description,
              short_description: assembly.short_description,
              slug: assembly.slug,
              access_mode: assembly.access_mode,
              weight: assembly.weight
            }
          end

          it "uses the slug param as assembly id" do
            expect(AssemblyForm).to receive(:from_params).with(hash_including(id: assembly.id.to_s)).and_call_original

            patch :update, params: { slug: assembly.id, assembly: assembly_params }

            expect(response).to redirect_to(edit_assembly_path(assembly.slug))
          end
        end

        it_behaves_like "a soft-deletable space",
                        space_name: :assembly,
                        space_path: :assemblies_path,
                        trash_path: :manage_trash_assemblies_path
      end
    end
  end
end
