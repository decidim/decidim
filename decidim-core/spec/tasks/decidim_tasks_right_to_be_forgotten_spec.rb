# frozen_string_literal: true

require "spec_helper"
require "support/tasks"

describe "rake decidim:right_to_be_forgotten", type: :task do
  let(:file_path) { Rails.root.join("tmp", "forgotten_users.csv") }
  let!(:original_stdout) { $stdout }

  let(:user) { create(:user, :confirmed) }
  let(:user2) { create(:user, :confirmed) }
  let(:deleted_user) { create(:user, :confirmed, :deleted) }
  let(:users) { [user, user2] }

  # rubocop:disable RSpec/ExpectOutput
  before do
    File.delete(Rails.root.join("log", "right_to_be_forgotten.log")) if File.exist?(Rails.root.join("log", "right_to_be_forgotten.log"))
    $stdout = StringIO.new
  end

  after do
    delete_forgotten_users_file
    $stdout = original_stdout
  end
  # rubocop:enable RSpec/ExpectOutput

  it "preloads the Rails environment" do
    expect(task.prerequisites).to include "environment"
  end

  context "when file is correct" do
    it "runs gracefully" do
      create_forgotten_users_file
      expect { task.execute }.not_to raise_error
      not_errors_raised
    end

    it "deletes users" do
      user_ids = users.collect(&:id)
      create_forgotten_users_file(user_ids)
      task.execute
      not_errors_raised
      expect(Decidim::User.where(id: user_ids).all?(&:deleted?)).to be true
      message_raised("[#{user_ids.first}] DELETING USER")
    end

    it "ignores not found users" do
      user_id = user
      create_forgotten_users_file([user_id, 123_456])
      task.execute
      message_raised("[123456] User not found")
    end

    it "ignores already deleted users" do
      user_ids = [user, deleted_user].collect(&:id)
      create_forgotten_users_file(user_ids)
      task.execute
      message_raised("[#{deleted_user.id}] User already deleted")
    end

    it "creates a log file" do
      user_ids = users.collect(&:id)
      create_forgotten_users_file(user_ids)
      task.execute
      expect(File.exist?(Rails.root.join("log", "right_to_be_forgotten.log"))).to be true
    end
  end

  context "when file do not exists" do
    it "raise a FILE NOT FOUND error" do
      expect(ENV).to receive(:[]).with("FILE_PATH").and_return("tmp/not_found_file")
      task.execute
      error_raised("File not found")
    end
  end

  context "when file is bad formatted" do
    before do
      f = File.open(file_path, "w")
      f.write("1',\"")
      f.close
    end

    it "raise a MALFORMED CSV error" do
      task.execute
      error_raised("Malformed CSV")
    end
  end
end

def not_errors_raised
  expect($stdout.string).not_to include("ERROR:")
end

def errors_raised
  expect($stdout.string).to include("ERROR:")
end

def error_raised(type = "File not found")
  expect($stdout.string).to include("ERROR: [#{type}]")
end

def message_raised(message = "RightToBeForgotten")
  expect($stdout.string).to include(message)
end

def create_forgotten_users_file(user_ids = [1])
  CSV.open(file_path, "w") do |csv|
    user_ids.each do |user_id|
      csv << [user_id]
    end
  end
end

def delete_forgotten_users_file
  File.delete(file_path) if File.exist?(file_path)
end
