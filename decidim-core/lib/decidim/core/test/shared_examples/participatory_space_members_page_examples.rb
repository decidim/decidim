# frozen_string_literal: true

shared_examples "participatory space members page examples" do
  let(:user1) { create(:user, organization: participatory_space.organization) }
  let(:user2) { create(:user, organization: participatory_space.organization) }
  let(:user3) { create(:user, organization: participatory_space.organization) }

  before do
    request.env["decidim.current_organization"] = organization
  end

  describe "GET index" do
    context "when participatory space has no members" do
      it "redirects to 404" do
        expect { get :index, params: { slug_param => slug, :locale => I18n.locale } }
          .to raise_error(ActionController::RoutingError)
      end
    end

    context "when participatory space has members" do
      let!(:member1) { create(:member, participatory_space:, user: user1, published: true) }
      let!(:member2) { create(:member, participatory_space:, user: user2, published: true) }
      let!(:non_published) { create(:member, participatory_space:, user: user3, published: false) }

      context "when user has permissions" do
        it "displays list of members" do
          get :index, params: { slug_param => slug, :locale => I18n.locale }

          expect(controller.helpers.collection).to contain_exactly(member1, member2)
        end
      end

      context "when user does not have permissions" do
        before do
          allow(controller).to receive(:current_user_can_visit_space?).and_return(false)
        end

        it "redirects to participatory space path" do
          get :index, params: { slug_param => slug, :locale => I18n.locale }

          expect(response).to redirect_to(destination_path)
        end
      end
    end

    context "when participatory space has paginated members" do
      let(:users) { create_list(:user, 30, organization: participatory_space.organization) }
      let!(:members) do
        users.map do |user|
          create(:member, participatory_space:, user:, published: true)
        end
      end

      context "with default pagination" do
        it "returns first page with 25 members" do
          get :index, params: { slug_param => slug, :locale => I18n.locale }

          expect(assigns(:members).count).to eq(25)
          expect(assigns(:members).current_page).to eq(1)
          expect(assigns(:members).total_count).to eq(30)
        end
      end

      context "with page parameter" do
        it "returns second page with remaining members" do
          get :index, params: { slug_param => slug, :locale => I18n.locale, :page => 2 }

          expect(assigns(:members).count).to eq(5)
          expect(assigns(:members).current_page).to eq(2)
          expect(assigns(:members).total_count).to eq(30)
        end

        it "returns empty collection for out-of-range page" do
          get :index, params: { slug_param => slug, :locale => I18n.locale, :page => 999 }

          expect(assigns(:members).count).to eq(0)
          expect(assigns(:members).current_page).to eq(999)
          expect(assigns(:members).total_count).to eq(30)
        end
      end

      context "with per_page parameter" do
        it "returns all members when per_page is 50" do
          get :index, params: { slug_param => slug, :locale => I18n.locale, :per_page => 50 }

          expect(assigns(:members).count).to eq(30)
          expect(assigns(:members).current_page).to eq(1)
          expect(assigns(:members).limit_value).to eq(50)
          expect(assigns(:members).total_count).to eq(30)
        end

        it "returns first 25 members when per_page is 25" do
          get :index, params: { slug_param => slug, :locale => I18n.locale, :per_page => 25 }

          expect(assigns(:members).count).to eq(25)
          expect(assigns(:members).limit_value).to eq(25)
        end

        it "limits per_page to maximum allowed value" do
          get :index, params: { slug_param => slug, :locale => I18n.locale, :per_page => 200 }

          expect(assigns(:members).limit_value).to eq(100)
        end

        it "limit per_page to minimum allowed value" do
          get :index, params: { slug_param => slug, :locale => I18n.locale, :per_page => 5 }

          expect(assigns(:members).limit_value).to eq(25)
        end
      end

      context "with both page and per_page parameters" do
        it "returns correct page with custom per_page" do
          get :index, params: { slug_param => slug, :locale => I18n.locale, :page => 2, :per_page => 50 }

          expect(assigns(:members).count).to eq(0)
          expect(assigns(:members).current_page).to eq(2)
          expect(assigns(:members).limit_value).to eq(50)
        end
      end
    end
  end
end
