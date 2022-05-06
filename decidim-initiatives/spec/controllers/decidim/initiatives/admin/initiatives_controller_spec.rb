# frozen_string_literal: true

require "spec_helper"

describe Decidim::Initiatives::Admin::InitiativesController, type: :controller do
  routes { Decidim::Initiatives::AdminEngine.routes }

  let(:user) { create(:user, :confirmed, organization: organization) }
  let(:admin_user) { create(:user, :admin, :confirmed, organization: organization) }
  let(:organization) { create(:organization) }
  let!(:initiative) { create(:initiative, organization: organization) }
  let!(:created_initiative) { create(:initiative, :created, organization: organization) }

  before do
    request.env["decidim.current_organization"] = organization
  end

  context "when index" do
    context "and Users without initiatives" do
      before do
        sign_in user, scope: :user
      end

      it "initiative list is not allowed" do
        get :index
        expect(flash[:alert]).not_to be_empty
        expect(response).to have_http_status(:found)
      end
    end

    context "and anonymous users do" do
      it "initiative list is not allowed" do
        get :index
        expect(flash[:alert]).not_to be_empty
        expect(response).to have_http_status(:found)
      end
    end

    context "and admin users" do
      before do
        sign_in admin_user, scope: :user
      end

      it "initiative list is allowed" do
        get :index
        expect(flash[:alert]).to be_nil
        expect(response).to have_http_status(:ok)
      end
    end

    context "and initiative author" do
      before do
        sign_in initiative.author, scope: :user
      end

      it "initiative list is allowed" do
        get :index
        expect(flash[:alert]).to be_nil
        expect(response).to have_http_status(:ok)
      end
    end

    describe "and promotal committee members" do
      before do
        sign_in initiative.committee_members.approved.first.user, scope: :user
      end

      it "initiative list is allowed" do
        get :index
        expect(flash[:alert]).to be_nil
        expect(response).to have_http_status(:ok)
      end
    end
  end

  context "when edit" do
    context "and Users without initiatives" do
      before do
        sign_in user, scope: :user
      end

      it "are not allowed" do
        get :edit, params: { slug: initiative.to_param }
        expect(flash[:alert]).not_to be_empty
        expect(response).to have_http_status(:found)
      end
    end

    context "and anonymous users" do
      it "are not allowed" do
        get :edit, params: { slug: initiative.to_param }
        expect(flash[:alert]).not_to be_empty
        expect(response).to have_http_status(:found)
      end
    end

    context "and admin users" do
      before do
        sign_in admin_user, scope: :user
      end

      it "are allowed" do
        get :edit, params: { slug: initiative.to_param }
        expect(flash[:alert]).to be_nil
        expect(response).to have_http_status(:ok)
      end
    end

    context "and initiative author" do
      before do
        sign_in initiative.author, scope: :user
      end

      it "are allowed" do
        get :edit, params: { slug: initiative.to_param }
        expect(flash[:alert]).to be_nil
        expect(response).to have_http_status(:ok)
      end
    end

    context "and promotal committee members" do
      before do
        sign_in initiative.committee_members.approved.first.user, scope: :user
      end

      it "are allowed" do
        get :edit, params: { slug: initiative.to_param }
        expect(flash[:alert]).to be_nil
        expect(response).to have_http_status(:ok)
      end
    end
  end

  context "when update" do
    let(:valid_attributes) do
      attrs = attributes_for(:initiative, organization: organization)
      attrs[:signature_end_date] = I18n.l(attrs[:signature_end_date], format: :decidim_short)
      attrs[:signature_start_date] = I18n.l(attrs[:signature_start_date], format: :decidim_short)
      attrs
    end

    context "and Users without initiatives" do
      before do
        sign_in user, scope: :user
      end

      it "are not allowed" do
        put :update,
            params: {
              slug: initiative.to_param,
              initiative: valid_attributes
            }
        expect(flash[:alert]).not_to be_empty
        expect(response).to have_http_status(:found)
      end
    end

    context "and anonymous users do" do
      it "are not allowed" do
        put :update,
            params: {
              slug: initiative.to_param,
              initiative: valid_attributes
            }
        expect(flash[:alert]).not_to be_empty
        expect(response).to have_http_status(:found)
      end
    end

    context "and admin users" do
      before do
        sign_in admin_user, scope: :user
      end

      it "are allowed" do
        put :update,
            params: {
              slug: initiative.to_param,
              initiative: valid_attributes
            }
        expect(flash[:alert]).to be_nil
        expect(response).to have_http_status(:found)
      end
    end

    context "and initiative author" do
      context "and initiative published" do
        before do
          sign_in initiative.author, scope: :user
        end

        it "are not allowed" do
          put :update,
              params: {
                slug: initiative.to_param,
                initiative: valid_attributes
              }
          expect(flash[:alert]).not_to be_nil
          expect(response).to have_http_status(:found)
        end
      end

      context "and initiative created" do
        let(:initiative) { create(:initiative, :created, organization: organization) }

        before do
          sign_in initiative.author, scope: :user
        end

        it "are allowed" do
          put :update,
              params: {
                slug: initiative.to_param,
                initiative: valid_attributes
              }
          expect(flash[:alert]).to be_nil
          expect(response).to have_http_status(:found)
        end
      end
    end

    context "and promotal committee members" do
      context "and initiative published" do
        before do
          sign_in initiative.committee_members.approved.first.user, scope: :user
        end

        it "are not allowed" do
          put :update,
              params: {
                slug: initiative.to_param,
                initiative: valid_attributes
              }
          expect(flash[:alert]).not_to be_nil
          expect(response).to have_http_status(:found)
        end
      end

      context "and initiative created" do
        let(:initiative) { create(:initiative, :created, organization: organization) }

        before do
          sign_in initiative.committee_members.approved.first.user, scope: :user
        end

        it "are allowed" do
          put :update,
              params: {
                slug: initiative.to_param,
                initiative: valid_attributes
              }
          expect(flash[:alert]).to be_nil
          expect(response).to have_http_status(:found)
        end
      end
    end
  end

  context "when GET send_to_technical_validation" do
    context "and Initiative in created state" do
      context "and has not enough committee members" do
        before do
          created_initiative.author.confirm
          sign_in created_initiative.author, scope: :user
        end

        it "does not pass to technical validation phase" do
          created_initiative.type.update(minimum_committee_members: 4)
          get :send_to_technical_validation, params: { slug: created_initiative.to_param }

          created_initiative.reload
          expect(created_initiative).not_to be_validating
        end

        it "does pass to technical validation phase" do
          created_initiative.type.update(minimum_committee_members: 3)
          get :send_to_technical_validation, params: { slug: created_initiative.to_param }

          created_initiative.reload
          expect(created_initiative).to be_validating
        end
      end

      context "and User is not the owner of the initiative" do
        let(:other_user) { create(:user, organization: organization) }

        before do
          sign_in other_user, scope: :user
        end

        it "Raises an error" do
          get :send_to_technical_validation, params: { slug: created_initiative.to_param }
          expect(flash[:alert]).not_to be_empty
          expect(response).to have_http_status(:found)
        end
      end

      context "and User is the owner of the initiative. It is in created state" do
        before do
          created_initiative.author.confirm
          sign_in created_initiative.author, scope: :user
        end

        it "Passes to technical validation phase" do
          get :send_to_technical_validation, params: { slug: created_initiative.to_param }

          created_initiative.reload
          expect(created_initiative).to be_validating
        end
      end
    end

    context "and Initiative in discarded state" do
      let!(:discarded_initiative) { create(:initiative, :discarded, organization: organization) }

      before do
        sign_in discarded_initiative.author, scope: :user
      end

      it "Passes to technical validation phase" do
        get :send_to_technical_validation, params: { slug: discarded_initiative.to_param }

        discarded_initiative.reload
        expect(discarded_initiative).to be_validating
      end
    end

    context "and Initiative not in created or discarded state (published)" do
      before do
        sign_in initiative.author, scope: :user
      end

      it "Raises an error" do
        get :send_to_technical_validation, params: { slug: initiative.to_param }
        expect(flash[:alert]).not_to be_empty
        expect(response).to have_http_status(:found)
      end
    end
  end

  context "when POST publish" do
    let!(:initiative) { create(:initiative, :validating, organization: organization) }

    context "and Initiative owner" do
      before do
        sign_in initiative.author, scope: :user
      end

      it "Raises an error" do
        post :publish, params: { slug: initiative.to_param }
        expect(flash[:alert]).not_to be_empty
        expect(response).to have_http_status(:found)
      end
    end

    context "and Administrator" do
      let!(:admin) { create(:user, :confirmed, :admin, organization: organization) }

      before do
        sign_in admin, scope: :user
      end

      it "initiative gets published" do
        post :publish, params: { slug: initiative.to_param }
        expect(response).to have_http_status(:found)

        initiative.reload
        expect(initiative).to be_published
        expect(initiative.published_at).not_to be_nil
        expect(initiative.signature_start_date).not_to be_nil
        expect(initiative.signature_end_date).not_to be_nil
      end
    end
  end

  context "when DELETE unpublish" do
    context "and Initiative owner" do
      before do
        sign_in initiative.author, scope: :user
      end

      it "Raises an error" do
        delete :unpublish, params: { slug: initiative.to_param }
        expect(flash[:alert]).not_to be_empty
        expect(response).to have_http_status(:found)
      end
    end

    context "and Administrator" do
      let(:admin) { create(:user, :confirmed, :admin, organization: organization) }

      before do
        sign_in admin, scope: :user
      end

      it "initiative gets unpublished" do
        delete :unpublish, params: { slug: initiative.to_param }
        expect(response).to have_http_status(:found)

        initiative.reload
        expect(initiative).not_to be_published
        expect(initiative).to be_discarded
        expect(initiative.published_at).to be_nil
      end
    end
  end

  context "when DELETE discard" do
    let(:initiative) { create(:initiative, :validating, organization: organization) }

    context "and Initiative owner" do
      before do
        sign_in initiative.author, scope: :user
      end

      it "Raises an error" do
        delete :discard, params: { slug: initiative.to_param }
        expect(flash[:alert]).not_to be_empty
        expect(response).to have_http_status(:found)
      end
    end

    context "and Administrator" do
      let(:admin) { create(:user, :confirmed, :admin, organization: organization) }

      before do
        sign_in admin, scope: :user
      end

      it "initiative gets discarded" do
        delete :discard, params: { slug: initiative.to_param }
        expect(response).to have_http_status(:found)

        initiative.reload
        expect(initiative).to be_discarded
        expect(initiative.published_at).to be_nil
      end
    end
  end

  context "when POST accept" do
    let!(:initiative) { create(:initiative, :acceptable, signature_type: "any", organization: organization) }

    context "and Initiative owner" do
      before do
        sign_in initiative.author, scope: :user
      end

      it "Raises an error" do
        post :accept, params: { slug: initiative.to_param }
        expect(flash[:alert]).not_to be_empty
        expect(response).to have_http_status(:found)
      end
    end

    context "when Administrator" do
      let!(:admin) { create(:user, :confirmed, :admin, organization: organization) }

      before do
        sign_in admin, scope: :user
      end

      it "initiative gets published" do
        post :accept, params: { slug: initiative.to_param }
        expect(response).to have_http_status(:found)

        initiative.reload
        expect(initiative).to be_accepted
      end
    end
  end

  context "when DELETE reject" do
    let!(:initiative) { create(:initiative, :rejectable, signature_type: "any", organization: organization) }

    context "and Initiative owner" do
      before do
        sign_in initiative.author, scope: :user
      end

      it "Raises an error" do
        delete :reject, params: { slug: initiative.to_param }
        expect(flash[:alert]).not_to be_empty
        expect(response).to have_http_status(:found)
      end
    end

    context "when Administrator" do
      let!(:admin) { create(:user, :confirmed, :admin, organization: organization) }

      before do
        sign_in admin, scope: :user
      end

      it "initiative gets rejected" do
        delete :reject, params: { slug: initiative.to_param }
        expect(response).to have_http_status(:found)
        expect(flash[:alert]).to be_nil

        initiative.reload
        expect(initiative).to be_rejected
      end
    end
  end

  context "when GET export_votes" do
    let(:initiative) { create(:initiative, organization: organization, signature_type: "any") }

    context "and author" do
      before do
        sign_in initiative.author, scope: :user
      end

      it "is not allowed" do
        get :export_votes, params: { slug: initiative.to_param, format: :csv }
        expect(flash[:alert]).not_to be_empty
        expect(response).to have_http_status(:found)
      end
    end

    context "and promotal committee" do
      before do
        sign_in initiative.committee_members.approved.first.user, scope: :user
      end

      it "is not allowed" do
        get :export_votes, params: { slug: initiative.to_param, format: :csv }
        expect(flash[:alert]).not_to be_empty
        expect(response).to have_http_status(:found)
      end
    end

    context "and admin user" do
      let!(:vote) { create(:initiative_user_vote, initiative: initiative) }

      before do
        sign_in admin_user, scope: :user
      end

      it "is allowed" do
        get :export_votes, params: { slug: initiative.to_param, format: :csv }
        expect(flash[:alert]).to be_nil
        expect(response).to have_http_status(:ok)
      end
    end
  end

  context "when GET export_pdf_signatures" do
    let(:initiative) { create(:initiative, :with_user_extra_fields_collection, organization: organization) }

    context "and author" do
      before do
        sign_in initiative.author, scope: :user
      end

      it "is not allowed" do
        get :export_pdf_signatures, params: { slug: initiative.to_param, format: :pdf }
        expect(flash[:alert]).not_to be_empty
        expect(response).to have_http_status(:found)
      end
    end

    context "and admin" do
      before do
        sign_in admin_user, scope: :user
      end

      it "is allowed" do
        get :export_pdf_signatures, params: { slug: initiative.to_param, format: :pdf }
        expect(flash[:alert]).to be_nil
        expect(response).to have_http_status(:ok)
      end
    end
  end

  context "when GET export" do
    context "and user" do
      before do
        sign_in user, scope: :user
      end

      it "is not allowed" do
        expect(Decidim::Initiatives::ExportInitiativesJob).not_to receive(:perform_later).with(user, "CSV", nil)

        get :export, params: { format: :csv }
        expect(flash[:alert]).not_to be_empty
        expect(response).to have_http_status(:found)
      end
    end

    context "and admin" do
      before do
        sign_in admin_user, scope: :user
      end

      it "is allowed" do
        expect(Decidim::Initiatives::ExportInitiativesJob).to receive(:perform_later).with(admin_user, organization, "csv", nil)

        get :export, params: { format: :csv }
        expect(flash[:alert]).to be_nil
        expect(response).to have_http_status(:found)
      end

      context "when a collection of ids is passed as a parameter" do
        let!(:initiatives) { create_list(:initiative, 3, organization: organization) }
        let(:collection_ids) { initiatives.map(&:id) }

        it "enqueues the job" do
          expect(Decidim::Initiatives::ExportInitiativesJob).to receive(:perform_later).with(admin_user, organization, "csv", collection_ids)

          get :export, params: { format: :csv, collection_ids: collection_ids }
          expect(flash[:alert]).to be_nil
          expect(response).to have_http_status(:found)
        end
      end
    end
  end
end
