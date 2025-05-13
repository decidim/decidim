# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module CollaborativeTexts
    describe DocumentType, type: :graphql do
      include_context "with a graphql class type"

      let(:model) { create(:collaborative_text_document, :published, :with_versions) }

      include_examples "traceable interface"
      include_examples "timestamps interface"

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
        let(:query) { "{ title }" }

        it "returns all the required fields" do
          expect(response["title"]).to eq(model.title)
        end
      end

      describe "body" do
        let(:query) { "{ body }" }

        it "returns all the required fields" do
          expect(response["body"]).to eq(model.body)
        end
      end

      describe "author" do
        let(:query) { "{ author { name } authors { name } }" }

        it "returns nil when the author is the organization" do
          expect(response["author"]).to be_nil
        end

        context "when has coauthors" do
          let(:user) { create(:user, :confirmed, organization: model.participatory_space.organization) }

          before do
            model.add_coauthor(user)
            model.save!
          end

          it "returns the user's name as the coauthors" do
            expect(response["author"]).to be_nil

            expect(response["authors"]).to include("name" => user.name)
          end
        end
      end

      describe "document_versions" do
        let(:query) { "{ documentVersions { id } }" }

        it "returns all the required fields" do
          expect(response["documentVersions"].count).to eq(model.document_versions.count)
          expect(response["documentVersions"].map { |v| v["id"] }).to match_array(model.document_versions.map(&:id).map(&:to_s))
        end
      end

      describe "suggestions" do
        let!(:suggestions) { create_list(:collaborative_text_suggestion, 2, document_version: model.current_version) }
        let(:query) { "{ suggestions { id } }" }

        it "returns all the required fields" do
          expect(response["suggestions"].count).to eq(suggestions.count)
          expect(response["suggestions"].map { |s| s["id"] }).to match_array(suggestions.map(&:id).map(&:to_s))
        end
      end

      context "when participatory space is private" do
        let(:participatory_space) { create(:participatory_process, :with_steps, :private, organization: current_organization) }
        let(:current_component) { create(:collaborative_text_component, participatory_space:) }
        let(:model) { create(:collaborative_text_document, :published, component: current_component) }
        let(:query) { "{ id }" }

        it "returns nothing" do
          expect(response).to be_nil
        end
      end

      context "when participatory space is private but transparent" do
        let(:participatory_space) { create(:assembly, :private, :transparent, organization: current_organization) }
        let(:current_component) { create(:collaborative_text_component, participatory_space:) }
        let(:model) { create(:collaborative_text_document, :published, component: current_component) }
        let(:query) { "{ id }" }

        it "returns the model" do
          expect(response).to include("id" => model.id.to_s)
        end
      end

      context "when participatory space is not published" do
        let(:participatory_space) { create(:participatory_process, :with_steps, :unpublished, organization: current_organization) }
        let(:current_component) { create(:collaborative_text_component, participatory_space:) }
        let(:model) { create(:collaborative_text_document, :published, component: current_component) }
        let(:query) { "{ id }" }

        it "returns nothing" do
          expect(response).to be_nil
        end
      end

      context "when component is not published" do
        let(:current_component) { create(:collaborative_text_component, :unpublished, organization: current_organization) }
        let(:model) { create(:collaborative_text_document, :published, component: current_component) }
        let(:query) { "{ id }" }

        it "returns nothing" do
          expect(response).to be_nil
        end
      end

      context "when document is not published" do
        let(:current_component) { create(:collaborative_text_component, :unpublished, organization: current_organization) }
        let(:model) { create(:collaborative_text_document, :published, published_at: nil, component: current_component) }
        let(:query) { "{ id }" }

        it "returns nothing" do
          expect(response).to be_nil
        end
      end
    end
  end
end
