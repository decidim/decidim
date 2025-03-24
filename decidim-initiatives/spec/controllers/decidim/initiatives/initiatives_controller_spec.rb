# frozen_string_literal: true

require "spec_helper"

describe Decidim::Initiatives::InitiativesController do
  routes { Decidim::Initiatives::Engine.routes }

  let(:organization) { create(:organization) }
  let!(:initiative) { create(:initiative, organization:) }
  let!(:created_initiative) { create(:initiative, :created, organization:) }

  before do
    request.env["decidim.current_organization"] = organization
  end

  describe "GET index" do
    it "Only returns published initiatives" do
      get :index, params: { locale: I18n.locale }
      expect(subject.helpers.initiatives).to include(initiative)
      expect(subject.helpers.initiatives).not_to include(created_initiative)
    end

    context "when no order is given" do
      let(:voted_initiative) { create(:initiative, organization:) }
      let!(:vote) { create(:initiative_user_vote, initiative: voted_initiative) }
      let!(:initiatives_settings) { create(:initiatives_settings, :most_signed) }

      it "return in the default order" do
        get :index, params: { order: "most_voted", locale: I18n.locale }

        expect(subject.helpers.initiatives.first).to eq(voted_initiative)
      end
    end

    context "when order by most_voted" do
      let(:voted_initiative) { create(:initiative, organization:) }
      let!(:vote) { create(:initiative_user_vote, initiative: voted_initiative) }

      it "most voted appears first" do
        get :index, params: { order: "most_voted", locale: I18n.locale }

        expect(subject.helpers.initiatives.first).to eq(voted_initiative)
      end
    end

    context "when order by most recent" do
      let!(:old_initiative) { create(:initiative, organization:, created_at: initiative.created_at - 12.months) }

      it "most recent appears first" do
        get :index, params: { order: "recent", locale: I18n.locale }
        expect(subject.helpers.initiatives.first).to eq(initiative)
      end
    end

    context "when order by most recently published" do
      let!(:old_initiative) { create(:initiative, organization:, published_at: initiative.published_at - 12.months) }

      it "most recent appears first" do
        get :index, params: { order: "recently_published", locale: I18n.locale }
        expect(subject.helpers.initiatives.first).to eq(initiative)
      end
    end

    context "when order by most commented" do
      let(:commented_initiative) { create(:initiative, organization:) }
      let!(:comment) { create(:comment, commentable: commented_initiative) }

      it "most commented appears first" do
        get :index, params: { order: "most_commented", locale: I18n.locale }
        expect(subject.helpers.initiatives.first).to eq(commented_initiative)
      end
    end
  end

  describe "GET show" do
    context "and any user" do
      it "Shows published initiatives" do
        get :show, params: { slug: initiative.slug, locale: I18n.locale }
        expect(subject.helpers.current_initiative).to eq(initiative)
      end

      it "Returns 404 when there is not an initiative" do
        expect { get :show, params: { slug: "invalid-initiative", locale: I18n.locale } }
          .to raise_error(ActiveRecord::RecordNotFound)
      end

      it "Throws exception on non published initiatives" do
        get :show, params: { slug: created_initiative.slug, locale: I18n.locale }
        expect(flash[:alert]).not_to be_empty
        expect(response).to have_http_status(:found)
      end
    end

    context "and initiative Owner" do
      before do
        sign_in created_initiative.author, scope: :user
      end

      it "Unpublished initiatives are shown too" do
        get :show, params: { slug: created_initiative.slug, locale: I18n.locale }
        expect(subject.helpers.current_initiative).to eq(created_initiative)
      end
    end
  end

  describe "Edit initiative as promoter" do
    include ActionView::Helpers::TextHelper

    before do
      sign_in created_initiative.author, scope: :user
    end

    let(:valid_attributes) do
      attrs = attributes_for(:initiative, organization:)
      attrs[:title] = truncate(translated(attrs[:title]), length: 150, omission: "")
      attrs[:description] = Decidim::HtmlTruncation.new(translated(attrs[:description]), max_length: 150, tail: "").perform
      attrs[:signature_end_date] = I18n.l(attrs[:signature_end_date], format: :decidim_short)
      attrs[:signature_start_date] = I18n.l(attrs[:signature_start_date], format: :decidim_short)
      attrs[:type_id] = created_initiative.type.id
      attrs
    end

    it "edit when user is allowed" do
      get :edit, params: { slug: created_initiative.slug, locale: I18n.locale }
      expect(flash[:alert]).to be_nil
      expect(response).to have_http_status(:ok)
    end

    context "and update an initiative" do
      it "are allowed" do
        put :update,
            params: {
              slug: created_initiative.to_param,
              initiative: valid_attributes,
              locale: I18n.locale
            }
        expect(flash[:alert]).to be_nil
        expect(response).to have_http_status(:found)
      end
    end

    context "when initiative is invalid" do
      it "does not update when title is nil" do
        invalid_attributes = valid_attributes.merge(title: nil)

        put :update,
            params: {
              slug: created_initiative.to_param,
              initiative: invalid_attributes,
              locale: I18n.locale
            }

        expect(flash[:alert]).not_to be_empty
        expect(response).to have_http_status(:ok)
      end

      context "when the existing initiative has attachments and there are other errors on the form" do
        let!(:created_initiative) do
          create(
            :initiative,
            :created,
            :with_photos,
            :with_documents,
            organization:
          )
        end

        include_context "with controller rendering the view" do
          let(:invalid_attributes) do
            valid_attributes.merge(
              title: nil,
              photos: created_initiative.photos.map { |a| a.id.to_s },
              documents: created_initiative.documents.map { |a| a.id.to_s }
            )
          end

          it "displays the editing form with errors" do
            put :update, params: {
              slug: created_initiative.to_param,
              initiative: invalid_attributes,
              locale: I18n.locale
            }

            expect(flash[:alert]).not_to be_empty
            expect(response).to have_http_status(:ok)
            expect(subject).to render_template(:edit)
            expect(response.body).to include("There was a problem updating the initiative.")
          end
        end
      end
    end
  end
end
