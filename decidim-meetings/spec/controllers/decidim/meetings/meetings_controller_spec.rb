# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::MeetingsController do
  include Decidim::Core::Engine.routes.url_helpers

  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let(:meeting_component) { create(:meeting_component, :with_creation_enabled, participatory_space: participatory_process) }
  let(:meeting) { create(:meeting, :published, component: meeting_component) }

  before do
    request.env["decidim.current_organization"] = organization
    request.env["decidim.current_participatory_space"] = participatory_process
    request.env["decidim.current_component"] = meeting_component
  end

  shared_examples "having meeting access visibility applied" do
    it "can access non private meetings" do
      get :show, params: { id: meeting.id }

      expect(subject).to render_template(:show)
      expect(flash[:alert]).to be_blank
    end

    it "can access private but transparent meetings" do
      meeting.update(private_meeting: true, transparent: true)

      get :show, params: { id: meeting.id }

      expect(subject).to render_template(:show)
      expect(flash[:alert]).to be_blank
    end

    it "can access private and non transparent meetings" do
      meeting.update(private_meeting: true, transparent: false)

      get :show, params: { id: meeting.id }

      expect(subject).to render_template(:show)
      expect(flash[:alert]).to be_blank
    end
  end

  describe "withdraw a meeting" do
    let(:user) { create(:user, :confirmed, organization: meeting_component.organization) }

    let(:meeting_params) do
      {
        component_id: meeting_component.id
      }
    end
    let(:params) { { meeting: meeting_params, id: meeting.id } }

    context "when an authorized user is withdrawing a meeting" do
      let(:meeting) { create(:meeting, component: meeting_component, author: user) }

      before { sign_in user }

      it "withdraws the meeting" do
        put(:withdraw, params:)

        expect(flash[:notice]).to eq("The meeting has been withdrawn successfully.")
        expect(response).to have_http_status(:found)
        meeting.reload
        expect(meeting.withdrawn?).to be true
      end
    end

    context "when current user is NOT the author of the meeting" do
      let(:current_user) { create(:user, :confirmed, organization: meeting_component.organization) }
      let(:meeting) { create(:meeting, component: meeting_component, author: current_user) }

      before { sign_in user }

      it "is not able to withdraw the meeting" do
        put(:withdraw, params:)

        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
        expect(response).to have_http_status(:found)
        meeting.reload
        expect(meeting.withdrawn?).to be false
      end
    end

    context "when user is not authenticated" do
      let(:user) { nil }

      it "redirects to login page" do
        put(:withdraw, params:)
        expect(flash[:alert]).to eq("You need to log in or create an account before continuing.")
        expect(response).to redirect_to(new_user_session_path)
        meeting.reload
        expect(meeting.withdrawn?).to be false
      end
    end
  end

  describe "#show" do
    context "when user is not logged in" do
      it "can access non private meetings" do
        get :show, params: { id: meeting.id }

        expect(subject).to render_template(:show)
        expect(flash[:alert]).to be_blank
      end

      context "with an online meeting" do
        let(:meeting) { create(:meeting, :published, :online, component: meeting_component) }

        it "does not allow CSP injection through online_meeting_url" do
          meeting.update!(online_meeting_url: "https://meet.evil.example/?a=1;script-src-elem 'none';report-uri https://attacker.example/collect")

          expect { get :show, params: { id: meeting.id } }.not_to raise_error

          csp = response.headers["Content-Security-Policy"]
          expect(csp).not_to include("report-uri https://attacker.example/collect")
          expect(csp).not_to include("script-src-elem 'none'")
          expect(csp).to include("frame-src 'self' www.youtube-nocookie.com player.vimeo.com")
        end

        it "does not allow CSP injection via an allowed host with CSP-breaking characters" do
          meeting.update!(online_meeting_url: "https://meet.jit.si/room;script-src-elem 'none';report-uri https://attacker.example/collect")

          expect { get :show, params: { id: meeting.id } }.not_to raise_error

          csp = response.headers["Content-Security-Policy"]
          expect(csp).not_to include("report-uri https://attacker.example/collect")
          expect(csp).not_to include("script-src-elem 'none'")
          expect(csp).to include("frame-src 'self' www.youtube-nocookie.com player.vimeo.com")
        end

        context "when online_meeting_url points to an embeddable service" do
          let(:meeting) do
            create(:meeting, :published, :online, :embeddable, component: meeting_component)
          end

          it "adds the transformed URL to frame-src" do
            get :show, params: { id: meeting.id }

            csp = response.headers["Content-Security-Policy"]
            expect(csp).to include("frame-src 'self' www.youtube-nocookie.com player.vimeo.com https://www.youtube-nocookie.com/embed/pj_2G3x6-Zk")
          end
        end

        context "when online_meeting_url uses an allowlisted host with a malicious path" do
          it "does not crash and keeps the frame-src directive clean" do
            meeting.update!(online_meeting_url: "https://meet.jit.si/room;script-src-elem 'none'")

            expect { get :show, params: { id: meeting.id } }.not_to raise_error
            expect(response).to render_template(:show)

            csp = response.headers["Content-Security-Policy"]
            expect(csp).not_to include("script-src-elem 'none'")
            expect(csp).to include("frame-src 'self' www.youtube-nocookie.com player.vimeo.com")
          end
        end
      end

      it "can access private but transparent meetings" do
        meeting.update(private_meeting: true, transparent: true)

        get :show, params: { id: meeting.id }

        expect(subject).to render_template(:show)
        expect(flash[:alert]).to be_blank
      end

      it "cannot access private and non transparent meetings" do
        meeting.update(private_meeting: true, transparent: false)

        get :show, params: { id: meeting.id }

        expect(flash[:alert]).to include("You are not authorized to perform this action.")
      end
    end

    context "with signed in user" do
      before { sign_in user }

      context "when user is admin" do
        let!(:user) { create(:user, :admin, :confirmed, organization:) }

        it_behaves_like "having meeting access visibility applied"
      end

      context "when user is process admin" do
        let!(:user) { create(:user, :confirmed, organization:) }
        let!(:participatory_process_user_role) { create(:participatory_process_user_role, user:, participatory_process:) }

        it_behaves_like "having meeting access visibility applied"

        context "when meeting is unpublished" do
          let(:meeting) { create(:meeting, component: meeting_component) }

          it "process admin successfully sees the meeting" do
            get :show, params: { id: meeting.id }

            expect(subject).to render_template(:show)
            expect(flash[:alert]).to be_blank
          end
        end
      end

      context "when user is member" do
        let!(:user) { create(:user, :confirmed, organization:) }
        let!(:member) { create(:member, user:, participatory_space: participatory_process) }

        it_behaves_like "having meeting access visibility applied"
      end

      context "when user has registered to the meeting" do
        let!(:user) { create(:user, :confirmed, organization:) }
        let!(:registration) { create(:registration, user:, meeting:) }

        it_behaves_like "having meeting access visibility applied"
      end
    end
  end

  describe "#new" do
    context "when user is not logged in" do
      it "redirects to the login page" do
        get(:new)
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "#create" do
    let(:meeting_params) do
      {
        component_id: meeting_component.id
      }
    end
    let(:params) { { meeting: meeting_params } }

    context "when user is not authenticated" do
      it "redirects to login page" do
        post(:create, params:)
        expect(flash[:alert]).to eq("You need to log in or create an account before continuing.")
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "#edit" do
    let(:meeting_params) do
      {
        component_id: meeting_component.id
      }
    end
    let(:params) { { meeting: meeting_params, id: meeting.id } }

    context "when user is not authenticated" do
      it "redirects to login page" do
        get(:edit, params:)
        expect(flash[:alert]).to eq("You need to log in or create an account before continuing.")
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "#update" do
    let(:meeting_params) do
      {
        component_id: meeting_component.id
      }
    end
    let(:params) { { meeting: meeting_params, id: meeting.id } }

    context "when user is not authenticated" do
      it "redirects to login page" do
        put(:update, params:)
        expect(flash[:alert]).to eq("You need to log in or create an account before continuing.")
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
