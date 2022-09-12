# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe OrganizationController, type: :controller do
      routes { Decidim::Admin::Engine.routes }

      let(:organization) { create :organization }
      let(:current_user) { create(:user, :admin, :confirmed, organization:) }

      before do
        request.env["decidim.current_organization"] = organization
        sign_in current_user, scope: :user
      end

      describe "GET users and user groups in json format" do
        let!(:user) { create(:user, name: "Daisy Miller", nickname: "daisy_m", organization:, email: "d.mail@example.org") }
        let!(:other_user) { create(:user, name: "Daisy O'connor", nickname: "daisy_o", email: "d.mail.o@example.org") }
        let!(:user_group) do
          create(
            :user_group,
            :verified,
            name: "Daisy Organization",
            nickname: "daisy_org",
            email: "d.mail.org@example.org",
            users: [user],
            organization:
          )
        end
        let(:parsed_response) { JSON.parse(response.body).map(&:symbolize_keys) }

        context "when searching by name" do
          it "returns the id, name, email and nickname for filtered users and user groups" do
            get :user_entities, format: :json, params: { term: "daisy" }
            expect(parsed_response).to include({ value: user.id, label: "#{user.name} (@#{user.nickname}) #{user.email}" })
            expect(parsed_response).to include({ value: user_group.id, label: "#{user_group.name} (@#{user_group.nickname}) #{user_group.email}" })
            expect(parsed_response).not_to include({ value: other_user.id, label: "#{other_user.name} (@#{other_user.nickname}) #{other_user.email}" })
          end
        end

        context "when searching by nickname" do
          it "returns the id, name, email and nickname for filtered users and user groups" do
            get :user_entities, format: :json, params: { term: "@daisy" }
            expect(parsed_response).to include({ value: user.id, label: "#{user.name} (@#{user.nickname}) #{user.email}" })
            expect(parsed_response).to include({ value: user_group.id, label: "#{user_group.name} (@#{user_group.nickname}) #{user_group.email}" })
            expect(parsed_response).not_to include({ value: other_user.id, label: "#{other_user.name} (@#{other_user.nickname}) #{other_user.email}" })
          end
        end

        context "when searching by email" do
          it "returns the id, name, email and nickname for filtered users and user groups" do
            get :user_entities, format: :json, params: { term: "d.mail" }
            expect(parsed_response).to include({ value: user.id, label: "#{user.name} (@#{user.nickname}) #{user.email}" })
            expect(parsed_response).to include({ value: user_group.id, label: "#{user_group.name} (@#{user_group.nickname}) #{user_group.email}" })
            expect(parsed_response).not_to include({ value: other_user.id, label: "#{other_user.name} (@#{other_user.nickname}) #{other_user.email}" })
          end
        end
      end

      describe "GET users in json format" do
        let!(:user) { create(:user, name: "Daisy Miller", nickname: "daisy_m", organization:) }
        let!(:other_user) { create(:user, name: "Daisy O'connor", nickname: "daisy_o") }
        let!(:user_group) do
          create(
            :user_group,
            :verified,
            name: "Daisy Organization",
            nickname: "daysy_org",
            users: [user],
            organization:
          )
        end

        let(:parsed_response) { JSON.parse(response.body).map(&:symbolize_keys) }

        context "when no search term is provided" do
          it "returns an empty result set" do
            get :users, format: :json, params: {}
            expect(parsed_response).to eq([])
          end
        end

        context "when there are no results" do
          it "returns an empty json array" do
            get :users, format: :json, params: { term: "#0" }
            expect(parsed_response).to eq([])
          end
        end

        context "when searching by name" do
          it "returns the id, name, email and nickname for filtered users" do
            get :users, format: :json, params: { term: "daisy" }
            expect(parsed_response).to eq([{ value: user.id, label: "#{user.name} (@#{user.nickname}) #{user.email}" }])
          end
        end

        context "when searching by nickname" do
          it "returns the id, name, email and nickname for filtered users" do
            get :users, format: :json, params: { term: "@daisy" }
            expect(parsed_response).to eq([{ value: user.id, label: "#{user.name} (@#{user.nickname}) #{user.email}" }])
          end
        end

        context "when searching by email" do
          it "returns the id, name, email and nickname for filtered users" do
            get :users, format: :json, params: { term: user.email }
            expect(parsed_response).to eq([{ value: user.id, label: "#{user.name} (@#{user.nickname}) #{user.email}" }])
          end
        end
      end
    end
  end
end
