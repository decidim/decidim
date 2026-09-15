# frozen_string_literal: true

namespace :decidim do
  namespace :sessions do
    desc "Cleanup expired sessions."
    task :cleanup, [] => :environment do
      ActiveRecord::SessionStore::Session.where(updated_at: ...Decidim.remove_sessions_after.ago).delete_all
    end
  end
end
