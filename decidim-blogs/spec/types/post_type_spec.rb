# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Blogs
    describe PostType, type: :graphql do
      include_context "with a graphql class type"

      let(:model) { create(:post, :with_endorsements) }

      include_examples "attachable interface"
      include_examples "authorable interface"
      include_examples "traceable interface"
      include_examples "timestamps interface"
      include_examples "endorsable interface"
      include_examples "followable interface"

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

      describe "title" do
        let(:query) { '{ title { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["title"]["translation"]).to eq(model.title["en"])
        end
      end

      describe "body" do
        let(:query) { '{ body { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["body"]["translation"]).to eq(model.body["en"])
        end
      end

      context "when participatory space is private" do
        let(:participatory_space) { create(:participatory_process, :with_steps, :private, organization: current_organization) }
        let(:current_component) { create(:post_component, participatory_space:) }
        let(:model) { create(:post, component: current_component) }
        let(:query) { "{ id }" }

        it "returns nothing" do
          expect(response).to be_nil
        end
      end

      context "when participatory space is private but transparent" do
        let(:participatory_space) { create(:assembly, :private, :transparent, organization: current_organization) }
        let(:current_component) { create(:post_component, participatory_space:) }
        let(:model) { create(:post, component: current_component) }
        let(:query) { "{ id }" }

        it "returns the model" do
          expect(response).to include("id" => model.id.to_s)
        end
      end

      context "when participatory space is not published" do
        let(:participatory_space) { create(:participatory_process, :with_steps, :unpublished, organization: current_organization) }
        let(:current_component) { create(:post_component, participatory_space:) }
        let(:model) { create(:post, component: current_component) }
        let(:query) { "{ id }" }

        it "returns nothing" do
          expect(response).to be_nil
        end
      end

      context "when component is not published" do
        let(:current_component) { create(:post_component, :unpublished, organization: current_organization) }
        let(:model) { create(:post, component: current_component) }
        let(:query) { "{ id }" }

        it "returns nothing" do
          expect(response).to be_nil
        end
      end

      context "when post is moderated" do
        let(:model) { create(:post, :hidden) }
        let(:query) { "{ id }" }
        let(:root_value) { model.reload }

        it "returns all the required fields" do
          expect(response).to be_nil
        end
      end

      context "when post is not published" do
        let(:current_component) { create(:post_component, :unpublished, organization: current_organization) }
        let(:model) { create(:post, published_at: nil, component: current_component) }
        let(:query) { "{ id }" }

        it "returns nothing" do
          expect(response).to be_nil
        end
      end
    end
  end
end
