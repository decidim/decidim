# frozen_string_literal: true

shared_examples "participatory space members page examples" do
  let(:user1) { create(:user, organization: privatable_to.organization) }
  let(:user2) { create(:user, organization: privatable_to.organization) }
  let(:user3) { create(:user, organization: privatable_to.organization) }

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
      let!(:member1) { create(:participatory_space_private_user, privatable_to:, user: user1, published: true) }
      let!(:member2) { create(:participatory_space_private_user, privatable_to:, user: user2, published: true) }
      let!(:non_published) { create(:participatory_space_private_user, privatable_to:, user: user3, published: false) }

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
  end
end
