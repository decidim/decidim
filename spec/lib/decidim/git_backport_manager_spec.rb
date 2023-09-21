# frozen_string_literal: true

require "fileutils"

require "decidim/git_backport_manager"

describe Decidim::GitBackportManager do
  subject { described_class.new(pull_request_id:, release_branch:, backport_branch:, working_dir: tmp_repository_dir) }

  let(:release_branch) { "release/0.99-stable" }
  let(:backport_branch) { "backport/fix-something-9876" }
  let(:pull_request_id) { 9_876 }
  let(:tmp_repository_dir) { "/tmp/decidim-git-backport-manager-test-#{rand(1_000)}" }
  let(:working_dir) { File.expand_path("../../..", __dir__) }

  before do
    FileUtils.mkdir_p("#{tmp_repository_dir}/code")
    Dir.chdir("#{tmp_repository_dir}/code")
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

  describe "#initialize" do
    let(:backport_branch) { "backport/fix-`top`something-9876" }

    it "sets the backport_branch as expected" do
      expect(subject.send(:backport_branch)).to eq("backport/fix-topsomething-9876")
    end

    context "when the branch name has a dot" do
      let(:backport_branch) { "backport/0.26/fix-something-9876" }

      it "sets the backport_branch as expected" do
        expect(subject.send(:backport_branch)).to eq("backport/0.26/fix-something-9876")
      end
    end
  end

  describe "#checkout_develop" do
    it "changes the branch to develop" do
      `
        git checkout #{release_branch}
      `

      described_class.checkout_develop

      expect { system("git branch --show-current") }.to output(/develop/).to_stdout_from_any_process
    end
  end

  describe ".create_backport_branch!" do
    let(:remote_repository_dir) { "#{tmp_repository_dir}/fake-remote/decidim/decidim/repository.git" }

    before do
      `
        git init --bare #{remote_repository_dir}
        git remote add origin #{remote_repository_dir}
      `
    end

    after do
      FileUtils.rm_rf(remote_repository_dir)
    end

    context "when there is a branch already with that name" do
      it "exits" do
        `
          git branch #{backport_branch}
        `

        expect { subject.send(:create_backport_branch!) }.to raise_error(SystemExit).and output(/Branch already exists locally/).to_stdout
      end
    end

    context "when the local repository is not up to date with the remote" do
      before do
        # Create a new commit and push it to the origin
        `
          git checkout #{release_branch}
          touch b_file.txt
          git add b_file.txt
          git commit -m "Another commit (#2345)"
          git push origin #{release_branch}
        `
      end

      it "pulls the remote changes before branching off" do
        sha_commit = `git rev-parse --short HEAD`.strip

        # Reset the last commit locally, so that the local repository is behind remote
        `git reset --hard @~`

        subject.send(:create_backport_branch!)

        # After the method the local release branch should be up to date with remote
        expect(`git rev-parse --short HEAD`.strip).to eq(sha_commit)
      end
    end

    context "when everything its ok" do
      it "creates the backport branch" do
        subject.send(:create_backport_branch!)

        expect { system("git branch --show-current") }.to output(/#{backport_branch}/).to_stdout_from_any_process
      end
    end
  end

  describe ".cherrypick_commit!" do
    it "cherrypicks the commit" do
      `
        git checkout develop
        touch another_file.txt
        git add another_file.txt
        git commit -m "Fix something (#9876)"
      `
      sha_commit = `git log --format=oneline | grep "(##{pull_request_id})"`.split.first
      `
        git checkout #{release_branch}
      `
      subject.send(:cherrypick_commit!, sha_commit)
      expect { system("git diff-tree --no-commit-id --name-only -r HEAD~1..HEAD") }.to output(/another_file.txt/).to_stdout_from_any_process
      expect { system("git log --format=oneline | wc -l") }.to output(/2/).to_stdout_from_any_process
    end
  end

  describe ".push_backport_branch!" do
    # Add /decidim/decidim in the path so it thinks it is in the decidim repository
    let(:remote_repository_dir) { "#{tmp_repository_dir}/fake-remote/decidim/decidim/repository.git" }

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

    it "exits when there is nothing to push" do
      `
        git checkout -b #{backport_branch}
      `

      expect { subject.send(:push_backport_branch!) }.to raise_error(SystemExit).and output(/Nothing to push to remote server/).to_stdout
    end

    it "is pushed when there is a branch to push" do
      `
        git checkout -b #{backport_branch}
        touch another_file.txt
        git add another_file.txt
        git commit -m "Fix something (#9876)"
      `

      expect { subject.send(:push_backport_branch!) }.to output(/Pushing branch/).to_stdout

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

      expect(subject.send(:sha_commit_to_backport).length).to eq 40
    end
  end

  describe ".exit_if_unstaged_changes" do
    it "exit with a warning if there are unstaged changes" do
      `
        echo change > a_file.txt
      `

      expect { subject.send(:exit_if_unstaged_changes) }.to raise_error(SystemExit).and output(/Please commit your changes or stash them/).to_stdout
    end
  end

  describe ".exit_with_errors" do
    it "exit with a custom message" do
      expect { subject.send(:exit_with_errors, "Bye") }.to raise_error(SystemExit).and output(/Bye/).to_stdout
    end
  end
end
