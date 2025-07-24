# frozen_string_literal: true

shared_examples "an authenticated vote controller" do
  describe "GET new" do
    it "renders the new vote form" do
      get :new, params: params
      expect(response).to have_http_status(:ok)
      expect(assigns(:form)).to be_a(Decidim::Elections::Censuses::InternalUsersForm)
      expect(subject).to render_template(:new)
    end

    context "when the user is authenticated" do
      before do
        sign_in user
      end

      it "redirects to the question path" do
        get :new, params: params
        expect(response).to redirect_to(election_vote_path)
      end
    end
  end

  describe "POST create" do
    it "renders the new form with errors when the form is invalid" do
      expect(controller).to receive(:redirect_to).with(action: :new)
      post :create, params: params

      expect(controller.send(:session_authenticated?)).to be false
      expect(controller.send(:voter_uid)).to be_nil
      expect(flash[:alert]).to be_present
    end

    context "with valid form data" do
      before do
        sign_in user
      end

      it "creates the session credentials and redirects to the question path" do
        post :create, params: params

        expect(session[:session_attributes]).to be_present
        expect(controller.send(:session_authenticated?)).to be true
        expect(controller.send(:voter_uid)).to eq(user.to_global_id.to_s)
        expect(response).to redirect_to(election_vote_path)
      end
    end
  end
end
