# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Headers
    describe "SessionUpdater" do
      controller do
        include Decidim::Headers::SessionUpdater

        def show
          render plain: "Hello World"
        end
      end

      let(:session_record) { ActiveRecord::SessionStore::Session.create!(session_id: "session-updater-spec", data: {}) }

      before do
        routes.draw { get "show" => "anonymous#show" }
      end

      context "when the session record is stored" do
        before do
          request.env["rack.session.record"] = session_record
        end

        it "updates the session record on the request" do
          previous_updated_at = session_record.updated_at

          travel(1.minute) do
            get :show

            expect(session_record.reload.updated_at).to be > previous_updated_at
          end
        end

        it "keeps the stored session data" do
          get :show

          expect(session_record.reload.data).to eq({})
        end
      end

      context "when there is no session record" do
        it "does not create a session record" do
          expect { get :show }.not_to change(ActiveRecord::SessionStore::Session, :count)

          expect(response).to be_successful
        end
      end

      context "when the session record is not saved yet" do
        let(:session_record) { ActiveRecord::SessionStore::Session.new(session_id: "session-updater-spec", data: {}) }

        before do
          request.env["rack.session.record"] = session_record
        end

        it "does not save the session record" do
          expect { get :show }.not_to change(ActiveRecord::SessionStore::Session, :count)

          expect(session_record).not_to be_persisted
        end
      end
    end
  end
end
