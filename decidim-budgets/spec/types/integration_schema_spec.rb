# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

describe "Decidim::Api::QueryType" do
  include_context "with a graphql decidim component" do
    let(:component_fragment) do
      %(
      fragment fooComponent on Budgets {
        budget(id: #{budget.id}) {
          createdAt
          description {
            translation(locale:"#{locale}")
          }
          id
          projects {
            acceptsNewComments
            address
            attachments{
              type
            }
            budget_amount
            comments{ id }
            commentsHaveAlignment
            commentsHaveVotes
            confirmedVotes
            coordinates { latitude longitude }
            createdAt
            description{ translation(locale: "#{locale}")}
            followsCount
            hasComments
            id
            reference
            taxonomies{ id }
            selected
            selectedAt
            title{ translation(locale: "#{locale}")}
            totalCommentsCount
            type
            updatedAt
            url
            userAllowedToComment
          }
          title {
            translation(locale:"#{locale}")
          }
          total_budget
          updatedAt
          url
          versions {
            id
          }
          versionsCount
          weight
        }
      }
    )
    end
  end
  let(:component_type) { "Budgets" }
  let!(:current_component) { create(:budgets_component, :published, participatory_space: participatory_process) }
  let!(:budget) { create(:budget, component: current_component) }
  let!(:projects) { create_list(:project, 2, :selected, budget:, taxonomies:) }

  let(:budget_single_result) do
    {
      "createdAt" => budget.created_at.to_time.iso8601,
      "description" => { "translation" => budget.description[locale] },
      "id" => budget.id.to_s,
      "projects" => budget.projects.map do |project|
        {
          "acceptsNewComments" => project.accepts_new_comments?,
          "address" => project.address,
          "attachments" => [],
          "budget_amount" => project.budget_amount,
          "taxonomies" => [{ "id" => project.taxonomies.first.id.to_s }],
          "comments" => [],
          "commentsHaveAlignment" => project.comments_have_alignment?,
          "commentsHaveVotes" => project.comments_have_votes?,
          "confirmedVotes" => nil,
          "coordinates" => { "latitude" => project.latitude, "longitude" => project.longitude },
          "createdAt" => project.created_at.to_time.iso8601,
          "description" => { "translation" => project.description[locale] },
          "followsCount" => project.follows_count,
          "hasComments" => project.comment_threads.size.positive?,
          "id" => project.id.to_s,
          "reference" => project.reference,
          "selected" => project.selected?,
          "selectedAt" => project.selected_at.to_time.iso8601,
          "title" => { "translation" => project.title[locale] },
          "totalCommentsCount" => project.comments_count,
          "type" => "Decidim::Budgets::Project",
          "updatedAt" => project.updated_at.to_time.iso8601,
          "userAllowedToComment" => project.user_allowed_to_comment?(current_user),
          "url" => project.resource_locator.url
        }
      end,
      "title" => { "translation" => budget.title[locale] },
      "total_budget" => budget.total_budget,
      "updatedAt" => budget.updated_at.to_time.iso8601,
      "url" => Decidim::EngineRouter.main_proxy(budget.component).budget_url(budget),
      "versions" => [],
      "versionsCount" => 0,
      "weight" => budget.weight
    }
  end

  let(:budgets_data) do
    {
      "__typename" => "Budgets",
      "id" => current_component.id.to_s,
      "name" => { "translation" => translated(current_component.name) },
      "budgets" => {
        "edges" => [
          {
            "node" => budget_single_result
          }
        ]
      },
      "url" => Decidim::EngineRouter.main_proxy(current_component).root_url,
      "weight" => 0
    }
  end

  describe "commentable" do
    let(:component_fragment) { nil }

    let(:participatory_process_query) do
      %(
        commentable(id: "#{projects.first.id}", type: "Decidim::Budgets::Project", locale: "en", toggleTranslations: false) {
          __typename
        }
      )
    end

    it "executes successfully" do
      expect { response }.not_to raise_error
    end

    it do
      expect(response).to eq({ "commentable" => { "__typename" => "Project" } })
    end
  end

  describe "valid connection query" do
    let(:budget_single_result) do
      {
        "createdAt" => budget.created_at.to_time.iso8601,
        "description" => { "translation" => budget.description[locale] },
        "id" => budget.id.to_s,
        "projects" => budget.projects.map { |project| { "id" => project.id.to_s } },
        "title" => { "translation" => budget.title[locale] },
        "total_budget" => budget.total_budget,
        "updatedAt" => budget.updated_at.to_time.iso8601,
        "url" => Decidim::EngineRouter.main_proxy(budget.component).budget_url(budget),
        "versions" => [],
        "versionsCount" => 0,
        "weight" => budget.weight
      }
    end

    let(:component_fragment) do
      %(
      fragment fooComponent on Budgets {
        budgets {
          edges{
            node{
              createdAt
              description {
                translation(locale:"#{locale}")
              }
              id
              projects {
                id
              }
              title {
                translation(locale:"#{locale}")
              }
              total_budget
              updatedAt
              url
              versions {
                id
              }
              versionsCount
              weight
            }
          }
        }
      }
    )
    end

    it "executes successfully" do
      expect { response }.not_to raise_error
    end

    it do
      expect(response["participatoryProcess"]["components"].first).to eq(budgets_data)
    end
  end

  describe "valid query" do
    it "executes successfully" do
      expect { response }.not_to raise_error
    end

    it do
      expect(response["participatoryProcess"]["components"].first["budget"]).to eq(budget_single_result)
    end
  end

  context "with resource visibility" do
    let(:component_factory) { :budgets_component }
    let(:lookout_key) { "budget" }
    let(:query_result) do
      {
        "createdAt" => budget.created_at.to_time.iso8601,
        "description" => { "translation" => budget.description[locale] },
        "id" => budget.id.to_s,
        "projects" => budget.projects.map do |project|
          {
            "acceptsNewComments" => project.accepts_new_comments?,
            "address" => project.address,
            "attachments" => [],
            "budget_amount" => project.budget_amount,
            "taxonomies" => [{ "id" => project.taxonomies.first.id.to_s }],
            "comments" => [],
            "commentsHaveAlignment" => project.comments_have_alignment?,
            "commentsHaveVotes" => project.comments_have_votes?,
            "confirmedVotes" => nil,
            "coordinates" => { "latitude" => project.latitude, "longitude" => project.longitude },
            "createdAt" => project.created_at.to_time.iso8601,
            "description" => { "translation" => project.description[locale] },
            "hasComments" => project.comment_threads.size.positive?,
            "followsCount" => project.follows_count,
            "id" => project.id.to_s,
            "reference" => project.reference,
            "selected" => project.selected?,
            "selectedAt" => project.selected_at.to_time.iso8601,
            "title" => { "translation" => project.title[locale] },
            "totalCommentsCount" => project.comments_count,
            "type" => "Decidim::Budgets::Project",
            "updatedAt" => project.updated_at.to_time.iso8601,
            "url" => project.resource_locator.url,
            "userAllowedToComment" => project.user_allowed_to_comment?(current_user)
          }
        end,
        "title" => { "translation" => budget.title[locale] },
        "total_budget" => budget.total_budget,
        "updatedAt" => budget.updated_at.to_time.iso8601,
        "url" => Decidim::EngineRouter.main_proxy(budget.component).budget_url(budget),
        "versions" => [],
        "versionsCount" => 0,
        "weight" => budget.weight
      }
    end
    let(:process_space_factory) { :participatory_process }

    context "when space is published" do
      let!(:participatory_process) { create(process_space_factory, :published, :with_steps, organization: current_organization) }

      context "when component is published" do
        let!(:current_component) { create(component_factory, :published, participatory_space: participatory_process) }

        context "when the user is admin" do
          let!(:current_user) { create(:user, :admin, :confirmed, organization: current_organization) }

          it "should be visible" do
            expect(response["participatoryProcess"]["components"].first[lookout_key]).to eq(query_result)
          end
        end

        context "when user is visitor" do
          let!(:current_user) { nil }

          it "should be visible" do
            expect(response["participatoryProcess"]["components"].first[lookout_key]).to eq(query_result.merge("projects" => [nil, nil]))
          end
        end

        context "when user is normal user" do
          let!(:current_user) { create(:user, :confirmed, organization: current_organization) }

          it "should be visible" do
            expect(response["participatoryProcess"]["components"].first[lookout_key]).to eq(query_result)
          end
        end
      end

      context "when component is not published" do
        let!(:current_component) { create(component_factory, :unpublished, participatory_space: participatory_process) }

        context "when the user is admin" do
          let!(:current_user) { create(:user, :admin, :confirmed, organization: current_organization) }

          it "should not be visible" do
            expect(response["participatoryProcess"]["components"].first[lookout_key]).to be_nil
          end
        end

        context "when user is visitor" do
          let!(:current_user) { nil }

          it "should not be visible" do
            expect(response["participatoryProcess"]["components"].first).to be_nil
          end
        end

        context "when user is normal user" do
          let!(:current_user) { create(:user, :confirmed, organization: current_organization) }

          it "should not be visible" do
            expect(response["participatoryProcess"]["components"].first).to be_nil
          end
        end
      end
    end

    context "when space is published but private" do
      let!(:participatory_process) { create(process_space_factory, :published, :private, :with_steps, organization: current_organization) }

      context "when component is published" do
        let!(:current_component) { create(component_factory, :published, participatory_space: participatory_process) }

        context "when the user is admin" do
          let!(:current_user) { create(:user, :admin, :confirmed, organization: current_organization) }

          it "should not be visible" do
            expect(response["participatoryProcess"]["components"].first[lookout_key]).to be_nil
          end
        end

        context "when user is visitor" do
          let!(:current_user) { nil }

          it "should not be visible" do
            expect(response["participatoryProcess"]).to be_nil
          end
        end

        context "when user is normal user" do
          let!(:current_user) { create(:user, :confirmed, organization: current_organization) }

          it "should not be visible" do
            expect(response["participatoryProcess"]).to be_nil
          end
        end
      end

      context "when component is not published" do
        let!(:current_component) { create(component_factory, :unpublished, participatory_space: participatory_process) }

        context "when the user is admin" do
          let!(:current_user) { create(:user, :admin, :confirmed, organization: current_organization) }

          it "should not be visible" do
            expect(response["participatoryProcess"]["components"].first[lookout_key]).to be_nil
          end
        end

        context "when user is visitor" do
          let!(:current_user) { nil }

          it "should not be visible" do
            expect(response["participatoryProcess"]).to be_nil
          end
        end

        context "when user is normal user" do
          let!(:current_user) { create(:user, :confirmed, organization: current_organization) }

          it "should not be visible" do
            expect(response["participatoryProcess"]).to be_nil
          end
        end
      end
    end

    context "when space is published, private and transparent" do
      let(:process_space_factory) { :assembly }
      let(:space_type) { "assembly" }

      let(:participatory_process_query) do
        %(
      assembly(id: #{participatory_process.id}) {
        components(filter: {type: "#{component_type}"}){
          id
          name {
            translation(locale: "#{locale}")
          }
          weight
          __typename
          ...fooComponent
        }
        id
      }
    )
      end
      let!(:participatory_process) { create(process_space_factory, :published, :private, :transparent, organization: current_organization) }

      context "when component is published" do
        let!(:current_component) { create(component_factory, :published, participatory_space: participatory_process) }

        context "when the user is admin" do
          let!(:current_user) { create(:user, :admin, :confirmed, organization: current_organization) }

          it "is visible" do
            expect(response["assembly"]["components"].first[lookout_key]).to eq(query_result)
          end
        end

        Decidim::AssemblyUserRole::ROLES.each do |role|
          context "when the user is space #{role}" do
            let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
            let!(:role) { create(:assembly_user_role, assembly: participatory_process, user: current_user, role:) }

            it "is visible" do
              expect(response["assembly"]["components"].first[lookout_key]).to eq(query_result)
            end
          end
        end

        context "when user is visitor" do
          let!(:current_user) { nil }

          it "is visible" do
            expect(response["assembly"]["components"].first[lookout_key]).to eq(query_result.merge("projects" => [nil, nil]))
          end
        end

        context "when user is member" do
          let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
          let!(:participatory_space_private_user) { create(:assembly_private_user, user: current_user, privatable_to: participatory_process) }

          it "is visible" do
            expect(response["assembly"]["components"].first[lookout_key]).to eq(query_result)
          end
        end

        context "when user is normal user" do
          let!(:current_user) { create(:user, :confirmed, organization: current_organization) }

          it "is visible" do
            expect(response["assembly"]["components"].first[lookout_key]).to eq(query_result)
          end
        end
      end

      context "when component is not published" do
        let!(:current_component) { create(component_factory, :unpublished, participatory_space: participatory_process) }

        context "when the user is admin" do
          let!(:current_user) { create(:user, :admin, :confirmed, organization: current_organization) }

          it "is visible" do
            expect(response["assembly"]["components"].first[lookout_key]).to be_nil
          end
        end

        %w(admin collaborator evaluator).each do |role|
          context "when the user is space #{role}" do
            let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
            let!(:role) { create(:assembly_user_role, assembly: participatory_process, user: current_user, role:) }

            it "is visible" do
              expect(response["assembly"]["components"].first[lookout_key]).to be_nil
            end
          end
        end
        context "when the user is space moderator" do
          let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
          let!(:role) { create(:assembly_user_role, assembly: participatory_process, user: current_user, role: "moderator") }

          it "is visible" do
            expect(response["assembly"]["components"].first).to be_nil
          end
        end

        context "when user is visitor" do
          let!(:current_user) { nil }

          it "should not be visible" do
            expect(response["assembly"]["components"].first).to be_nil
          end

          context "when user is member" do
            let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
            let!(:participatory_space_private_user) { create(:assembly_private_user, user: current_user, privatable_to: participatory_process) }

            it "should not be visible" do
              expect(response["assembly"]["components"].first).to be_nil
            end
          end
        end

        context "when user is normal user" do
          let!(:current_user) { create(:user, :confirmed, organization: current_organization) }

          it "should not be visible" do
            expect(response["assembly"]["components"].first).to be_nil
          end
        end
      end
    end

    context "when space is unpublished" do
      let(:participatory_process) { create(process_space_factory, :unpublished, :with_steps, organization: current_organization) }

      context "when component is published" do
        let!(:current_component) { create(component_factory, :published, participatory_space: participatory_process) }

        context "when the user is admin" do
          let!(:current_user) { create(:user, :admin, :confirmed, organization: current_organization) }

          it "should not be visible" do
            expect(response["participatoryProcess"]["components"].first[lookout_key]).to be_nil
          end
        end

        context "when user is visitor" do
          let!(:current_user) { nil }

          it "should not be visible" do
            expect(response["participatoryProcess"]).to be_nil
          end
        end

        context "when user is normal user" do
          let!(:current_user) { create(:user, :confirmed, organization: current_organization) }

          it "should not be visible" do
            expect(response["participatoryProcess"]).to be_nil
          end
        end
      end

      context "when component is not published" do
        let!(:current_component) { create(component_factory, :unpublished, participatory_space: participatory_process) }

        context "when the user is admin" do
          let!(:current_user) { create(:user, :admin, :confirmed, organization: current_organization) }

          it "should not be visible" do
            expect(response["participatoryProcess"]["components"].first[lookout_key]).to be_nil
          end
        end

        context "when user is visitor" do
          let!(:current_user) { nil }

          it "should not be visible" do
            expect(response["participatoryProcess"]).to be_nil
          end
        end

        context "when user is normal user" do
          let!(:current_user) { create(:user, :confirmed, organization: current_organization) }

          it "should not be visible" do
            expect(response["participatoryProcess"]).to be_nil
          end
        end
      end
    end
  end
end
