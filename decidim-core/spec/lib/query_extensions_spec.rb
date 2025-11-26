# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Core
    describe Decidim::Api::QueryType do
      include_context "with a graphql class type"

      describe "component" do
        let(:query) { %({ component(id: "#{id}") { id }}) }

        context "with a participatory space that belongs to the current organization" do
          let!(:component) { create(:dummy_component, participatory_space: participatory_process) }
          let(:participatory_process) { create(:participatory_process, organization: current_organization) }
          let(:id) { component.id }

          it "returns the component" do
            expect(response["component"]).to eq("id" => component.id.to_s)
          end
        end

        context "with a participatory space that does not belong to the current organization" do
          let!(:component) { create(:dummy_component) }
          let(:id) { component.id }

          it "returns the component" do
            expect(response["component"]).to be_nil
          end
        end
      end

      describe "decidim" do
        let(:query) { %({ decidim { version }}) }

        it "returns nil" do
          expect(response["decidim"]).to include("version" => nil)
        end

        context "when disclosing system version is enabled" do
          before do
            allow(Decidim::Api).to receive(:disclose_system_version).and_return(true)
          end

          it "returns the right version" do
            expect(response["decidim"]).to include("version" => Decidim.version)
          end
        end
      end

      describe "organization" do
        let(:query) { %({ organization { name { translation(locale: "en") } }}) }

        it "returns the current organization" do
          expect(response["organization"]["name"]["translation"]).to eq(translated(current_organization.name))
        end
      end

      describe "users" do
        let!(:user1) { create(:user, :confirmed, organization: current_organization) }
        let!(:user2) { create(:user, :confirmed, organization: current_organization) }
        let!(:user3) { create(:user, organization: current_organization) }
        let!(:user4) { create(:user, :confirmed) }

        let(:query) { %({ users { id }}) }

        it "returns all the users" do
          expect(response["users"]).to include("id" => user1.id.to_s)
          expect(response["users"]).to include("id" => user2.id.to_s)
          expect(response["users"]).not_to include("id" => user3.id.to_s)
          expect(response["users"]).not_to include("id" => user4.id.to_s)
        end
      end

      describe "moderated_users" do
        let(:user) { create(:user, :confirmed, :blocked, organization: current_organization) }
        let(:reporter) { create(:user, :confirmed, organization: current_organization) }
        let(:moderation) { create(:user_moderation, user:) }
        let!(:user_block) { create(:user_block, user:, blocking_user: reporter) }
        let!(:user_report) { create(:user_report, user: reporter, reason: "spam", details: "Lorem ipsum", moderation:) }

        let(:query) do
          %({
            moderatedUsers {
              about
              blockReasons
              blockedAt
              blockingUser {
                id
              }
              createdAt
              id
              reports {
                createdAt
                details
                id
                reason
                updatedAt
                user {
                  id
                }
              }
              updatedAt
              userId
            }
          })
        end

        it "returns all the moderated users" do
          expect(response["moderatedUsers"].last).to include(
            "about" => user.about,
            "blockReasons" => user_block.justification,
            "blockedAt" => user.blocked_at.to_time.iso8601,
            "blockingUser" => { "id" => user_block.blocking_user.id.to_s },
            "createdAt" => moderation.created_at.to_time.iso8601,
            "id" => moderation.id.to_s,
            "reports" => [
              {
                "createdAt" => user_report.created_at.to_time.iso8601,
                "details" => user_report.details,
                "id" => user_report.id.to_s,
                "reason" => user_report.reason,
                "updatedAt" => user_report.updated_at.to_time.iso8601,
                "user" => { "id" => user_report.user.id.to_s }
              }
            ],
            "updatedAt" => moderation.updated_at.to_time.iso8601,
            "userId" => user.id.to_s
          )
        end
      end

      describe "moderations" do
        let(:participatory_space) { create(:assembly, :published, organization: current_organization) }
        let(:component) { create(:dummy_component, :published, participatory_space:) }
        let(:commentable) { create(:dummy_resource, :published, component:) }
        let(:moderation) { create(:moderation, reportable: commentable, hidden_at: 2.days.ago, report_count: 1, reported_content: "This is the content") }
        let!(:report) { create(:report, moderation:, details: "This is a report", locale: "en") }

        let(:query) do
          %({
            moderations {
              createdAt
              hiddenAt
              id
              reportCount
              reportedContent
              reportedUrl
              reports {
                createdAt
                details
                id
                locale
                reason
                updatedAt
                user { id }
              }
              updatedAt
            }
          })
        end

        it "returns all the moderations" do
          expect(response["moderations"].last).to include(
            "createdAt" => moderation.created_at.to_time.iso8601,
            "hiddenAt" => moderation.hidden_at.to_time.iso8601,
            "id" => moderation.id.to_s,
            "reportCount" => moderation.reports.count,
            "reportedContent" => translated(moderation.reported_content),
            "reportedUrl" => moderation.reportable.reported_content_url,
            "reports" => [
              {
                "createdAt" => report.created_at.to_time.iso8601,
                "details" => report.details,
                "id" => report.id.to_s,
                "locale" => report.locale,
                "reason" => report.reason,
                "updatedAt" => report.updated_at.to_time.iso8601,
                "user" => { "id" => report.user.id.to_s }
              }
            ],
            "updatedAt" => moderation.updated_at.to_time.iso8601
          )
        end
      end

      describe "static_pages" do
        let!(:model) { create(:static_page, :with_topic, organization: current_organization) }

        let(:query) do
          %({
            staticPages{
              content {
                translation(locale: "en")
              }
              createdAt
              id
              title {
                translation(locale: "en")
              }
              topic {
                id
              }
              updatedAt
              url
            }
          })
        end

        it "returns all the static pages" do
          expect(response["staticPages"].last).to include(
            "content" => {
              "translation" => translated(model.content)
            },
            "createdAt" => model.created_at.to_time.iso8601,
            "id" => model.id.to_s,
            "title" => {
              "translation" => translated(model.title)
            },
            "topic" => {
              "id" => model.topic.id.to_s
            },
            "updatedAt" => model.updated_at.to_time.iso8601,
            "url" => Decidim::EngineRouter.new("decidim", { host: current_organization.host }).page_url(model.reload)
          )
        end
      end

      describe "static_page_topic" do
        let!(:model) { create(:static_page, :with_topic, organization: current_organization) }

        let(:static_page_topic) { model.topic }

        let(:query) do
          %({
            staticPageTopics{
              description{
                translation(locale: "en")
              }
              id
              showInFooter
              title {
                translation(locale: "en")
              }
            }
          })
        end

        it "returns all the static page topics" do
          expect(response["staticPageTopics"]).to include(
            "description" => {
              "translation" => translated(static_page_topic.description)
            },
            "id" => static_page_topic.id.to_s,
            "showInFooter" => static_page_topic.show_in_footer,
            "title" => {
              "translation" => translated(static_page_topic.title)
            }
          )
        end
      end

      describe "users with empty exclusion list" do
        let!(:user1) { create(:user, :confirmed, organization: current_organization) }
        let!(:user2) { create(:user, :confirmed, organization: current_organization) }
        let!(:user3) { create(:user, organization: current_organization) }
        let!(:user4) { create(:user, :confirmed) }
        let!(:user5) { create(:user, :confirmed, organization: current_organization) }
        let!(:user6) { create(:user, :confirmed, organization: current_organization) }
        let!(:exclusion_ids) { "" }

        let(:query) { %({ users(filter: { excludeIds: [#{exclusion_ids}] }) { id }}) }

        it "returns all the users without any exclusion" do
          expect(response["users"]).to include("id" => user1.id.to_s)
          expect(response["users"]).to include("id" => user2.id.to_s)
          expect(response["users"]).not_to include("id" => user3.id.to_s)
          expect(response["users"]).not_to include("id" => user4.id.to_s)
          expect(response["users"]).to include("id" => user5.id.to_s)
          expect(response["users"]).to include("id" => user6.id.to_s)
        end
      end

      describe "users with one user exclusion list" do
        let!(:user1) { create(:user, :confirmed, organization: current_organization) }
        let!(:user2) { create(:user, :confirmed, organization: current_organization) }
        let!(:user3) { create(:user, organization: current_organization) }
        let!(:user4) { create(:user, :confirmed) }
        let!(:user5) { create(:user, :confirmed, organization: current_organization) }
        let!(:user6) { create(:user, :confirmed, organization: current_organization) }
        let!(:exclusion_ids) { user5.id.to_s }

        let(:query) { %({ users(filter: { excludeIds: [#{exclusion_ids}] }) { id }}) }

        it "returns all the users except excluded one" do
          expect(response["users"]).to include("id" => user1.id.to_s)
          expect(response["users"]).to include("id" => user2.id.to_s)
          expect(response["users"]).not_to include("id" => user3.id.to_s)
          expect(response["users"]).not_to include("id" => user4.id.to_s)
          expect(response["users"]).not_to include("id" => user5.id.to_s)
          expect(response["users"]).to include("id" => user6.id.to_s)
        end
      end

      describe "users with multiple users exclusion list" do
        let!(:user1) { create(:user, :confirmed, organization: current_organization) }
        let!(:user2) { create(:user, :confirmed, organization: current_organization) }
        let!(:user3) { create(:user, organization: current_organization) }
        let!(:user4) { create(:user, :confirmed) }
        let!(:user5) { create(:user, :confirmed, organization: current_organization) }
        let!(:user6) { create(:user, :confirmed, organization: current_organization) }
        let!(:exclusion_ids) { "#{user5.id},#{user6.id}" }

        let(:query) { %({ users(filter: { excludeIds: [#{exclusion_ids}] }) { id }}) }

        it "returns all the users except excluded ones" do
          expect(response["users"]).to include("id" => user1.id.to_s)
          expect(response["users"]).to include("id" => user2.id.to_s)
          expect(response["users"]).not_to include("id" => user3.id.to_s)
          expect(response["users"]).not_to include("id" => user4.id.to_s)
          expect(response["users"]).not_to include("id" => user5.id.to_s)
          expect(response["users"]).not_to include("id" => user6.id.to_s)
        end
      end

      describe "participant_details" do
        include_context "with a graphql class type"

        let!(:participant) { create(:user, :confirmed, organization: current_organization) }
        let(:query) { %({ participantDetails(id: #{participant.id}){email name nickname}} ) }
        let(:user_type) { :user }

        let!(:current_user) do
          case user_type
          when :admin
            create(:user, :admin, :confirmed, organization: current_organization)
          when :api_user
            create(:api_user, organization: current_organization)
          else
            create(:user, :confirmed, organization: current_organization)
          end
        end

        context "with unauthorized user" do
          it "does not show participant details" do
            expect(response["participantDetails"]).to be_nil
          end
        end

        context "with an admin user" do
          let!(:user_type) { :admin }

          it_behaves_like "loggable participant details"
        end

        context "with an api user" do
          let!(:user_type) { :api_user }

          it_behaves_like "loggable participant details"
        end
      end
    end
  end
end
