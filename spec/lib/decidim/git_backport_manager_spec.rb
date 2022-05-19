# frozen_string_literal: true

require "fileutils"

require "decidim/git_backport_manager"

describe Decidim::GitBackportManager do
  let(:release_branch) { "release/0.99-stable" }
  let(:backport_branch) { "backport/fix-something-9876" }
  let(:manager) { described_class.new(pull_request_id: 9_876, release_branch: release_branch, backport_branch: backport_branch, working_dir: tmp_repository_dir) }

  let(:tmp_repository_dir) { "/tmp/decidim-git-backport-manager-test-#{rand(1_000)}" }
  let(:working_dir) { File.expand_path("../../..", __dir__) }

  before do
    Dir.mkdir(tmp_repository_dir)
    Dir.chdir(tmp_repository_dir)
    `
      git init --initial-branch=develop .
      git config user.email "decidim_git_backport_manager_test@example.com"
      git config user.name "Decidim::GitBackportManager test"

      touch a_file.txt
      git add a_file.txt
      git commit -m "Initial commit (#1234)"

      git branch #{release_branch}
    `
  end

  after do
    Dir.chdir(working_dir)
    FileUtils.rm_r(Dir.glob(tmp_repository_dir))
  end

  describe "#checkout_develop" do
    it "changes the branch to develop" do
      `git checkout #{release_branch}`
      described_class.checkout_develop

      expect { system("git branch --show-current") }.to output(/develop/).to_stdout_from_any_process
    end
  end

  describe ".create_backport_branch!" do
    it "creates the backport branch with the cherrypicked commit" do
      `
        touch another_file.txt
        git add another_file.txt
        git commit -m "Fix something (#9876)"
      `

      expect { manager.send(:create_backport_branch!) }.to output(/Cherrypicking commit/).to_stdout_from_any_process
      expect { system("git diff-tree --no-commit-id --name-only -r HEAD~1..HEAD") }.to output(/another_file.txt/).to_stdout_from_any_process
      expect { system("git log --format=oneline | wc -l") }.to output(/2/).to_stdout_from_any_process
    end
  end

  describe ".push_backport_branch!" do
    let(:remote_repository_dir) { "#{tmp_repository_dir}-remote.git" }

    before do
      `
        git init --bare #{remote_repository_dir}
        git remote add origin #{remote_repository_dir}
      `
    end

    after do
      Dir.chdir(working_dir)
      FileUtils.rm_rf(remote_repository_dir)
    end

    it "exits when there's nothing to push" do
      `git checkout -b #{backport_branch}`

      expect { manager.send(:push_backport_branch!) }.to raise_error(SystemExit).and output(/Nothing to push to remote server/).to_stdout
    end

    it "is pushed when there's a branch to push" do
      `
        git checkout -b #{backport_branch}
        touch another_file.txt
        git add another_file.txt
        git commit -m "Fix something (#9876)"
      `

      expect { manager.send(:push_backport_branch!) }.to output(/Pushing branch/).to_stdout

      Dir.chdir(remote_repository_dir)
      expect { system("git branch") }.to output(/#{backport_branch}/).to_stdout_from_any_process
    end
  end

  describe ".sha_commit_to_backport" do
    it "returns the SHA commit to backport" do
      `
        touch another_file.txt
        git add another_file.txt
        git commit -m "Fix something (#9876)"
      `

      expect(manager.send(:sha_commit_to_backport).length).to eq 40
    end
  end

  describe ".exit_if_unstaged_changes" do
    it "exit with a warning if there are unstaged changes" do
      `echo change > a_file.txt`

      expect { manager.send(:exit_if_unstaged_changes) }.to raise_error(SystemExit).and output(/Please commit your changes or stash them/).to_stdout
    end
  end

  describe ".exit_with_errors" do
    it "exit with a custom message" do
      expect { manager.send(:exit_with_errors, "Bye") }.to raise_error(SystemExit).and output(/Bye/).to_stdout
    end
  end
end
