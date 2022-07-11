# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Debate search", type: :request do
  include Decidim::ComponentPathHelper

  subject { response.body }

  let(:component) { create :debates_component }
  let(:participatory_space) { component.participatory_space }
  let(:organization) { participatory_space.organization }
  let(:filter_params) { {} }

  let!(:debate1) do
    create(
      :debate,
      :official,
      component:,
      start_time: 1.day.from_now
    )
  end
  let!(:debate2) do
    create(
      :debate,
      :official,
      component:,
      start_time: 2.days.from_now
    )
  end
  let!(:debate3) do
    create(
      :debate,
      :official,
      :closed,
      component:
    )
  end
  let!(:debate4) do
    create(
      :debate,
      :user_group_author,
      component:
    )
  end

  let(:request_path) { Decidim::EngineRouter.main_proxy(component).debates_path }

  before do
    get(
      request_path,
      params: { filter: filter_params },
      headers: { "HOST" => component.organization.host }
    )
  end

  it_behaves_like "a resource search", :debate
  it_behaves_like "a resource search with scopes", :debate
  it_behaves_like "a resource search with categories", :debate
  it_behaves_like "a resource search with origin", :debate

  it "displays all debates without any filters" do
    expect(subject).to have_escaped_html(translated(debate1.title))
    expect(subject).to have_escaped_html(translated(debate2.title))
    expect(subject).to have_escaped_html(translated(debate3.title))
    expect(subject).to have_escaped_html(translated(debate4.title))
  end

  context "when searching by text" do
    let(:filter_params) { { search_text_cont: search_text } }
    let(:search_text) { "doggo" }

    let!(:debate1) do
      create(
        :debate,
        :official,
        title: { en: "Do you like my doggo?" },
        component:,
        start_time: 1.day.from_now
      )
    end

    it "displays all debates without any filters" do
      expect(subject).to have_escaped_html(translated(debate1.title))
      expect(subject).not_to have_escaped_html(translated(debate2.title))
      expect(subject).not_to have_escaped_html(translated(debate3.title))
      expect(subject).not_to have_escaped_html(translated(debate4.title))
    end
  end

  context "when searching by state" do
    let(:filter_params) { { with_any_state: state } }

    context "and the state is open" do
      let(:state) { %w(open) }

      it "returns the open debates" do
        expect(subject).to have_escaped_html(translated(debate1.title))
        expect(subject).to have_escaped_html(translated(debate2.title))
        expect(subject).not_to have_escaped_html(translated(debate3.title))
        expect(subject).to have_escaped_html(translated(debate4.title))
      end
    end

    context "and the state is closed" do
      let(:state) { %w(closed) }

      it "returns the closed debates" do
        expect(subject).not_to have_escaped_html(translated(debate1.title))
        expect(subject).not_to have_escaped_html(translated(debate2.title))
        expect(subject).to have_escaped_html(translated(debate3.title))
        expect(subject).not_to have_escaped_html(translated(debate4.title))
      end
    end
  end

  context "when searching by activity" do
    let(:current_user) { create(:user, :confirmed, organization:) }

    before do
      login_as current_user, scope: :user
    end

    context "and the activity is commented" do
      let(:filter_params) { { activity: "commented" } }

      before do
        create(:comment, body: "This is a good debate!", commentable: debate4, author: current_user)

        get(
          request_path,
          params: { filter: filter_params },
          headers: { "HOST" => component.organization.host }
        )
      end

      it "returns the debates commented by the current user" do
        expect(subject).not_to have_escaped_html(translated(debate1.title))
        expect(subject).not_to have_escaped_html(translated(debate2.title))
        expect(subject).not_to have_escaped_html(translated(debate3.title))
        expect(subject).to have_escaped_html(translated(debate4.title))
      end
    end

    context "and the activity is my_debates" do
      let(:filter_params) { { activity: "my_debates" } }
      let(:current_user) { create(:user, :confirmed, organization:) }

      let!(:debate5) do
        create(
          :debate,
          component:,
          author: current_user
        )
      end

      before do
        get(
          request_path,
          params: { filter: filter_params },
          headers: { "HOST" => component.organization.host }
        )
      end

      it "returns the debates commented by the current user" do
        expect(subject).not_to have_escaped_html(translated(debate1.title))
        expect(subject).not_to have_escaped_html(translated(debate2.title))
        expect(subject).not_to have_escaped_html(translated(debate3.title))
        expect(subject).not_to have_escaped_html(translated(debate4.title))
        expect(subject).to have_escaped_html(translated(debate5.title))
      end
    end
  end
end
