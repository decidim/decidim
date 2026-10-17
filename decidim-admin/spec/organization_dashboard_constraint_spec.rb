# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe OrganizationDashboardConstraint do
      subject do
        response
        app.constraint_matches?
      end

      let(:response) { warden_manager.call(env) }
      let(:organization) { create(:organization) }
      let(:env) do
        {
          "decidim.current_organization" => organization,
          "rack.session" => {}
        }
      end
      let(:app) do
        Class.new do
          def initialize(constraint_class)
            @constraint_class = constraint_class
          end

          def call(env)
            @request = ActionDispatch::Request.new(env)
            @constraint_matches = @constraint_class.new(@request).matches?

            if constraint_matches?
              [200, {}, ["Hello"]]
            else
              [302, { "Location" => "/" }, ["Redirecting..."]]
            end
          end

          def constraint_matches?
            @constraint_matches == true
          end
        end.new(described_class)
      end
      let(:warden_manager) do
        opts = {
          failure_app: lambda { |_e|
            [401, {}, ["Unauthorized"]]
          }
        }
        Warden::Manager.new(app, opts)
      end

      around do |example|
        Warden::Manager.on_request do |proxy|
          proxy.set_user(user, scope: :user) if user
        end
        example.run
        Warden::Manager._on_request.pop
      end

      context "when authenticated" do
        context "with a regular user" do
          let(:user) { create(:user, :confirmed, organization:) }

          it { is_expected.to be_falsey }

          it "redirects" do
            expect(response[0]).to be(302)
          end
        end

        context "with an organization admin" do
          let(:user) { create(:user, :confirmed, :admin, organization:) }

          it { is_expected.to be_truthy }

          it "responds with HTTP OK" do
            expect(response[0]).to be(200)
          end
        end

        context "with an admin from another organization" do
          let(:other_organization) { create(:organization) }
          let(:user) { create(:user, :confirmed, :admin, organization: other_organization) }

          it { is_expected.to be_falsey }

          it "redirects" do
            expect(response[0]).to be(302)
          end
        end
      end

      context "when unauthenticated" do
        let(:user) { nil }

        it { is_expected.to be_falsey }

        it "calls the warden failure app" do
          expect(response[0]).to be(401)
        end

        context "with a before failure hook" do
          let(:dummy) { double }
          let(:failure_hook) { ->(env, options) { dummy.call(env, options) } }

          around do |example|
            Warden::Manager.before_failure(&failure_hook)
            example.run
            Warden::Manager._before_failure.pop
          end

          it "triggers an authentication failure hook call" do
            expect(dummy).to receive(:call)
            subject
          end

          context "when the failure hook is scoped" do
            let(:failure_hook) do
              lambda do |env, options|
                next if options[:context] == :admin_constraint

                dummy.call(env, options)
              end
            end

            it "does not call the failure handler" do
              expect(dummy).not_to receive(:call)
              subject
            end
          end
        end
      end
    end
  end
end
