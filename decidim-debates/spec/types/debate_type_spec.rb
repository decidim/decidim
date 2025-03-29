# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Debates
    describe DebateType, type: :graphql do
      include_context "with a graphql class type"

      let(:model) { create(:debate, :open_ama) }
      let(:organization) { model.organization }

      include_examples "taxonomizable interface"
      include_examples "authorable interface"
      include_examples "commentable interface"
      include_examples "timestamps interface"
      include_examples "followable interface"
      include_examples "referable interface"
      include_examples "attachable interface"
      include_examples "traceable interface"
      include_examples "endorsable interface" do
        let(:model) { create(:debate, :open_ama, :with_endorsements) }
      end

      describe "id" do
        let(:query) { "{ id }" }

        it "returns all the required fields" do
          expect(response).to include("id" => model.id.to_s)
        end
      end

      describe "url" do
        let(:query) { "{ url }" }

        it "returns all the required fields" do
          expect(response["url"]).to eq(Decidim::ResourceLocatorPresenter.new(model).url)
        end
      end

      describe "last_comment_at" do
        let(:model) { create(:debate, :open_ama, :with_endorsements, last_comment_at: 1.year.ago) }

        let(:query) { "{ lastCommentAt }" }

        it "returns all the required fields" do
          expect(response["lastCommentAt"]).to eq(model.last_comment_at.to_time.iso8601)
        end
      end

      describe "last_comment_by" do
        let(:last_comment_by) { create(:user, :confirmed, name: "User") }
        let(:model) { create(:debate, :open_ama, :with_endorsements, last_comment_by:) }
        let(:query) { "{ lastCommentBy { id } }" }

        it "returns all the required fields" do
          expect(response["lastCommentBy"]).to eq({ "id" => model.last_comment_by_id.to_s })
        end
      end

      describe "title" do
        let(:query) { '{ title { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["title"]["translation"]).to eq(model.title["en"])
        end
      end

      describe "description" do
        let(:query) { '{ description { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["description"]["translation"]).to eq(model.description["en"])
        end
      end

      describe "instructions" do
        let(:query) { '{ instructions { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["instructions"]["translation"]).to eq(model.instructions["en"])
        end
      end

      describe "conclusions" do
        let(:model) { create(:debate, :closed) }
        let(:query) { '{ conclusions { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["conclusions"]["translation"]).to eq(model.conclusions["en"])
        end
      end

      describe "comments_enabled" do
        let(:model) { create(:debate, :open_ama, comments_enabled: true) }
        let(:query) { "{ commentsEnabled }" }

        it "returns all the required fields" do
          expect(response["commentsEnabled"]).to eq(model.comments_enabled)
        end
      end

      describe "informationUpdates" do
        let(:query) { '{ informationUpdates { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["informationUpdates"]["translation"]).to eq(model.information_updates["en"])
        end
      end

      describe "startTime" do
        let(:query) { "{ startTime }" }

        it "returns the date when the debate starts" do
          expect(response["startTime"]).to eq(model.start_time.to_time.iso8601)
        end
      end

      describe "closedAt" do
        let(:model) { create(:debate, :closed) }
        let(:query) { "{ closedAt }" }

        it "returns the date when the debate closed" do
          expect(response["closedAt"]).to eq(model.closed_at.to_time.iso8601)
        end
      end

      describe "endTime" do
        let(:query) { "{ endTime }" }

        it "returns the date when the debate ends" do
          expect(response["endTime"]).to eq(model.end_time.to_time.iso8601)
        end
      end

      context "when participatory space is private" do
        let(:participatory_space) { create(:participatory_process, :with_steps, :private, organization: current_organization) }
        let(:current_component) { create(:debates_component, participatory_space:) }
        let(:model) { create(:debate, :open_ama, component: current_component) }
        let(:query) { "{ id }" }

        it "returns nothing" do
          expect(response).to be_nil
        end
      end

      context "when participatory space is private but transparent" do
        let(:participatory_space) { create(:assembly, :private, :transparent, organization: current_organization) }
        let(:current_component) { create(:debates_component, participatory_space:) }
        let(:model) { create(:debate, :open_ama, component: current_component) }
        let(:query) { "{ id }" }

        it "returns the model" do
          expect(response).to include("id" => model.id.to_s)
        end
      end

      context "when participatory space is not published" do
        let(:participatory_space) { create(:participatory_process, :with_steps, :unpublished, organization: current_organization) }
        let(:current_component) { create(:debates_component, participatory_space:) }
        let(:model) { create(:debate, :open_ama, component: current_component) }
        let(:query) { "{ id }" }

        it "returns nothing" do
          expect(response).to be_nil
        end
      end

      context "when component is not published" do
        let(:current_component) { create(:debates_component, :unpublished, organization: current_organization) }
        let(:model) { create(:debate, :open_ama, component: current_component) }
        let(:query) { "{ id }" }

        it "returns nothing" do
          expect(response).to be_nil
        end
      end

      context "when debate is moderated" do
        let(:model) { create(:debate, :open_ama, :hidden) }
        let(:query) { "{ id }" }
        let(:root_value) { model.reload }

        it "returns nothing" do
          expect(response).to be_nil
        end
      end
    end
  end
end
