# frozen_string_literal: true

require "spec_helper"

describe "rake decidim:upgrade:sidekiq", type: :task do
  around do |example|
    Dir.mktmpdir do |tmpdir|
      Dir.chdir(tmpdir) do
        example.run
      end
    end
  end

  it "copies the sidekiq configuration file" do
    task.execute

    expect(File).to exist("config/sidekiq.yml")
    expect(File.read("config/sidekiq.yml")).to eq(<<~YAML)
      :concurrency: <%= ENV.fetch("SIDEKIQ_CONCURRENCY", 5) %>
      :queues:
        - [mailers, 4]
        - [vote_reminder, 2]
        - [reminders, 2]
        - [default, 2]
        - [delete_inactive_participants, 2]
        - [newsletter, 2]
        - [newsletters_opt_in, 2]
        - [conference_diplomas, 2]
        - [events, 2]
        - [translations, 2]
        - [user_report, 2]
        - [block_user, 2]
        - [exports, 1]
        - [close_meeting_reminder, 1]
        - [spam_analysis, 1]
    YAML
  end
end
