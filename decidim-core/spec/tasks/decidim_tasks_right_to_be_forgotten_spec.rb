# frozen_string_literal: true

require "spec_helper"

describe "rake decidim:right_to_be_forgotten", type: :task do
  let(:file_path) { Rails.root.join("tmp/forgotten_users.csv") }

  let(:user) { create(:user, :confirmed) }
  let(:user2) { create(:user, :confirmed) }
  let(:deleted_user) { create(:user, :confirmed, :deleted) }
  let(:users) { [user, user2] }

  before do
    FileUtils.rm_f(Rails.root.join("log/right_to_be_forgotten.log"))
  end

  after do
    delete_forgotten_users_file
  end

  it "preloads the Rails environment" do
    expect(task.prerequisites).to include "environment"
  end

  context "when file is correct" do
    it "runs gracefully" do
      create_forgotten_users_file
      expect { task.execute }.not_to raise_error
      expect($stdout.string).not_to include("ERROR:")
    end

    it "deletes users" do
      user_ids = users.collect(&:id)
      create_forgotten_users_file(user_ids)
      task.execute
      expect($stdout.string).not_to include("ERROR:")
      expect(Decidim::User.where(id: user_ids).all?(&:deleted?)).to be true

      expect($stdout.string).to include("[#{user_ids.first}] DELETING USER")
    end

    it "ignores not found users" do
      user_id = user
      create_forgotten_users_file([user_id, 123_456])
      task.execute
      expect($stdout.string).to include("[123456] User not found")
    end

    it "ignores already deleted users" do
      user_ids = [deleted_user].collect(&:id)
      create_forgotten_users_file(user_ids)
      task.execute
      expect($stdout.string).to include("[#{deleted_user.id}] User already deleted")
    end

    it "creates a log file" do
      user_ids = users.collect(&:id)
      create_forgotten_users_file(user_ids)
      task.execute
      expect(Rails.root.join("log/right_to_be_forgotten.log").exist?).to be true
    end
  end

  context "when file do not exists" do
    it "raise a FILE NOT FOUND error" do
      allow(ENV).to receive(:[]).with("FILE_PATH").and_return("tmp/not_found_file")
      task.execute

      expect($stdout.string).to include("ERROR: [File not found]")
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
      expect($stdout.string).to include("ERROR: [Malformed CSV]")
    end
  end
end

def create_forgotten_users_file(user_ids = [1])
  CSV.open(file_path, "w") do |csv|
    user_ids.each do |user_id|
      csv << [user_id]
    end
  end
end

def delete_forgotten_users_file
  FileUtils.rm_f(file_path)
end
