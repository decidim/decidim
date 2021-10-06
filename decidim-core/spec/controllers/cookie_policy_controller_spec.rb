# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe CookiePolicyController, type: :controller do
    routes { Decidim::Core::Engine.routes }

    let(:organization) { create(:organization) }
    let(:extra_session_options) { {} }
    let(:session_options) { request.session_options.merge(extra_session_options) }

    before do
      request.env["decidim.current_organization"] = organization
      default_session_options session_options
    end

    after do
      default_session_options Rack::Session::Abstract::Persisted::DEFAULT_OPTIONS
    end

    describe "GET /accept" do
      it "sets the consent cookie for the user" do
        get :accept

        expect(response.cookies[Decidim.config.consent_cookie_name]).to eq("true")
        expect(response["Set-Cookie"]).to match(%r{^decidim-cc=true; path=/; expires=[^;]+; HttpOnly$})
      end

      context "when the session options define the secure flag" do
        let(:extra_session_options) { { secure: true } }

        it "sets the consent cookie for the user as secure" do
          get :accept

          expect(response.cookies[Decidim.config.consent_cookie_name]).to eq("true")
          expect(response["Set-Cookie"]).to match(%r{^decidim-cc=true; path=/; expires=[^;]+; secure; HttpOnly$})
        end
      end
    end

    private

    # Hack because there is no way to provide the session options through the
    # environment.
    #
    # See: https://github.com/rails/rails/blob/6-0-stable/actionpack/lib/action_controller/test_case.rb
    def default_session_options(options)
      ActionController::TestSession.send(:remove_const, :DEFAULT_OPTIONS)
      ActionController::TestSession.const_set(:DEFAULT_OPTIONS, options)
    end
  end
end
