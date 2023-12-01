# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Headers
    describe "ContentSecurityPolicy" do
      let!(:organization) { create(:organization) }
      let!(:user) { create(:user, :confirmed, organization:) }
      let!(:additional_content_security_policies) do
        {

          "default-src" => "https://example.org",
          "script-src" => "https://script.example.org",
          "style-src" => "https://style.example.org",
          "img-src" => "https://img.example.org",
          "font-src" => "https://font.example.org",
          "connect-src" => "https://connect.example.org",
          "frame-src" => "https://frame.example.org",
          "media-src" => "https://example.org"
        }
      end

      controller do
        include Decidim::Headers::ContentSecurityPolicy

        def current_organization
          request.env["decidim.current_organization"]
        end

        def show
          render plain: "Hello World"
        end
      end

      before do
        request.env["decidim.current_organization"] = organization
        routes.draw { get "show" => "anonymous#show" }
      end

      it "sets the appropiate headers" do
        get :show
        expect(response.headers["Content-Security-Policy"]).to include("default-src 'self' 'unsafe-inline'; ")
        expect(response.headers["Content-Security-Policy"]).to include("script-src 'self' 'unsafe-inline' 'unsafe-eval';")
        expect(response.headers["Content-Security-Policy"]).to include("style-src 'self' 'unsafe-inline';")
        expect(response.headers["Content-Security-Policy"]).to include("img-src 'self' *.hereapi.com data: https://via.placeholder.com;")
        expect(response.headers["Content-Security-Policy"]).to include("connect-src 'self' *.hereapi.com *.jsdelivr.net data:;")
        expect(response.headers["Content-Security-Policy"]).to include("font-src 'self';")
        expect(response.headers["Content-Security-Policy"]).to include("frame-src 'self' www.youtube-nocookie.com player.vimeo.com;")
        expect(response.headers["Content-Security-Policy"]).to include("media-src 'self'")
      end

      context "when content policy is added by organization" do
        let!(:organization) { create(:organization, content_security_policy: additional_content_security_policies) }

        it "sets the appropiate headers" do
          get :show
          expect(response.headers["Content-Security-Policy"]).to include("default-src 'self' 'unsafe-inline' https://example.org; ")
          expect(response.headers["Content-Security-Policy"]).to include("script-src 'self' 'unsafe-inline' 'unsafe-eval' https://script.example.org;")
          expect(response.headers["Content-Security-Policy"]).to include("style-src 'self' 'unsafe-inline' https://style.example.org;")
          expect(response.headers["Content-Security-Policy"]).to include("img-src 'self' *.hereapi.com data: https://via.placeholder.com https://img.example.org;")
          expect(response.headers["Content-Security-Policy"]).to include("connect-src 'self' *.hereapi.com *.jsdelivr.net data: https://connect.example.org;")
          expect(response.headers["Content-Security-Policy"]).to include("font-src 'self' https://font.example.org;")
          expect(response.headers["Content-Security-Policy"]).to include("frame-src 'self' www.youtube-nocookie.com player.vimeo.com https://frame.example.org;")
          expect(response.headers["Content-Security-Policy"]).to include("media-src 'self' https://example.org")
        end
      end

      context "when content policy is added via decidim config" do
        it "sets the appropiate headers" do
          allow(Decidim).to receive(:content_security_policies_extra).and_return(additional_content_security_policies)
          get :show
          expect(response.headers["Content-Security-Policy"]).to include("default-src 'self' 'unsafe-inline' https://example.org; ")
          expect(response.headers["Content-Security-Policy"]).to include("script-src 'self' 'unsafe-inline' 'unsafe-eval' https://script.example.org;")
          expect(response.headers["Content-Security-Policy"]).to include("style-src 'self' 'unsafe-inline' https://style.example.org;")
          expect(response.headers["Content-Security-Policy"]).to include("img-src 'self' *.hereapi.com data: https://img.example.org;")
          expect(response.headers["Content-Security-Policy"]).to include("connect-src 'self' *.hereapi.com *.jsdelivr.net data: https://connect.example.org;")
          expect(response.headers["Content-Security-Policy"]).to include("font-src 'self' https://font.example.org;")
          expect(response.headers["Content-Security-Policy"]).to include("frame-src 'self' www.youtube-nocookie.com player.vimeo.com https://frame.example.org;")
          expect(response.headers["Content-Security-Policy"]).to include("media-src 'self' https://example.org")
        end
      end

      context "when the organization has a content security policy" do
        controller do
          include Decidim::Headers::ContentSecurityPolicy

          def current_organization
            request.env["decidim.current_organization"]
          end

          before_action do |controller|
            {
              "default-src" => "https://example.org",
              "script-src" => "https://script.example.org",
              "style-src" => "https://style.example.org",
              "img-src" => "https://img.example.org",
              "font-src" => "https://font.example.org",
              "connect-src" => "https://connect.example.org",
              "frame-src" => "https://frame.example.org",
              "media-src" => "https://example.org"
            }.each do |key, value|
              controller.content_security_policy.append_csp_directive(key, value)
            end
          end

          def show
            render plain: "Hello World"
          end
        end

        before do
          request.env["decidim.current_organization"] = organization
          routes.draw { get "show" => "anonymous#show" }
        end

        it "sets the appropiate headers" do
          get :show
          expect(response.headers["Content-Security-Policy"]).to include("default-src 'self' 'unsafe-inline' https://example.org; ")
          expect(response.headers["Content-Security-Policy"]).to include("script-src 'self' 'unsafe-inline' 'unsafe-eval' https://script.example.org;")
          expect(response.headers["Content-Security-Policy"]).to include("style-src 'self' 'unsafe-inline' https://style.example.org;")
          expect(response.headers["Content-Security-Policy"]).to include("img-src 'self' *.hereapi.com data: https://img.example.org https://via.placeholder.com;")
          expect(response.headers["Content-Security-Policy"]).to include("connect-src 'self' *.hereapi.com *.jsdelivr.net data: https://connect.example.org;")
          expect(response.headers["Content-Security-Policy"]).to include("font-src 'self' https://font.example.org;")
          expect(response.headers["Content-Security-Policy"]).to include("frame-src 'self' www.youtube-nocookie.com player.vimeo.com https://frame.example.org;")
          expect(response.headers["Content-Security-Policy"]).to include("media-src 'self' https://example.org")
        end
      end
    end
  end
end
