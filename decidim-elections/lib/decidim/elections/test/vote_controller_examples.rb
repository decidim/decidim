# frozen_string_literal: true

def do_action(action)
  if [:show, :confirm, :waiting, :receipt].include?(action)
    get action, params: params
  else
    patch action, params: params
  end
end

shared_examples "an unauthenticated vote controller" do |action|
  it "redirects to the election path" do
    do_action(action)
    expect(response).to redirect_to(election_path)
  end

  it "redirects to the new per question vote path" do
    sign_in user
    election.update(results_availability: "per_question")
    do_action(action)
    expect(response).to redirect_to(new_election_per_question_vote_path)
  end
end

shared_examples "an unauthenticated per question vote controller" do |action|
  it "redirects to the election path" do
    do_action(action)
    expect(response).to redirect_to(election_path)
  end

  it "redirects to the new per question vote path" do
    sign_in user
    election.update(results_availability: "real_time")
    do_action(action)
    expect(response).to redirect_to(new_election_normal_vote_path)
  end
end

shared_examples "an authenticated vote controller" do
  describe "GET new" do
    it "renders the new vote form" do
      get :new, params: params
      expect(response).to have_http_status(:ok)
      expect(assigns(:form)).to be_a(Decidim::Elections::Censuses::InternalUsersForm)
      expect(subject).to render_template("decidim/elections/votes/new")
    end

    context "when the user is authenticated" do
      before do
        sign_in user
      end

      it "redirects to the question path" do
        expect(controller).to receive(:redirect_to).with(action: :show, id: question)
        get :new, params: params

        expect(controller.send(:session_authenticated?)).to be true
        expect(response).to render_template("decidim/elections/votes/new")
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

      it "creates the session credentials and redirects to form again" do
        expect(controller).to receive(:redirect_to).with(action: :show, id: question)
        post :create, params: params

        expect(session[:session_attributes]).to be_present
        expect(controller.send(:session_authenticated?)).to be true
        expect(controller.send(:voter_uid)).to eq(user.to_global_id.to_s)
      end
    end
  end
end

shared_examples "a redirect to the waiting room" do |action|
  it "redirects to the waiting page if waiting for next question" do
    allow(controller).to receive(:redirect_to).with(action: :show, id: question)
    allow(controller).to receive(:waiting_for_next_question?).and_return(true)

    expect(controller).to receive(:redirect_to).with(action: :waiting)
    do_action(action)
  end

  it "does not redirect if not waiting for next question" do
    allow(controller).to receive(:redirect_to).with(action: :show, id: question)

    do_action(action)
    expect(response).to render_template(action) unless action == :update
    expect(response).to have_http_status(:no_content) if action == :update
  end
end
