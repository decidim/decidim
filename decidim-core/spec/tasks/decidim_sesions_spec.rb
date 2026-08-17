# frozen_string_literal: true

require "spec_helper"

describe "rake decidim:sessions:cleanup", type: :task do
  context "when there are no sessions" do
    it "it passes run successfully when there are no sessions" do
      expect { task.execute }.not_to raise_error
    end
  end

  context "when there are old sessions" do
    let!(:old_session) { ActiveRecord::SessionStore::Session.create!(session_id: "123", data: "FOO BAR", updated_at: 5.days.ago) }
    let!(:new_session) { ActiveRecord::SessionStore::Session.create!(session_id: "456", data: "FOO BAR") }

    it "passes successfully when there are no sessions" do
      expect { task.execute }.not_to raise_error
    end

    it "removes candidate data" do
      expect { task.invoke }.to change(ActiveRecord::SessionStore::Session, :count).by(-1)
    end
  end
end
