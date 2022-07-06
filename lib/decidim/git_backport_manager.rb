# frozen_string_literal: true

require "English"

module Decidim
  class GitBackportManager
    def initialize(pull_request_id:, release_branch:, backport_branch:, working_dir: Dir.pwd, exit_with_unstaged_changes: false)
      @pull_request_id = pull_request_id
      @release_branch = release_branch
      @backport_branch = backport_branch
      @working_dir = working_dir
      @exit_with_unstaged_changes = exit_with_unstaged_changes
    end

    def call
      Dir.chdir(working_dir) do
        exit_if_unstaged_changes if @exit_with_unstaged_changes
        self.class.checkout_develop
        sha_commit = sha_commit_to_backport

        error_message = <<-EOERROR
        Could not find commit for pull request #{pull_request_id}.
        Please make sure you have pulled the latest changes.
        EOERROR
        exit_with_errors(error_message) unless sha_commit

        create_backport_branch!
        cherrypick_commit!(sha_commit)
        push_backport_branch!
      end
    end

    def self.checkout_develop
      `git checkout develop`

      error_message = <<-EOERROR
      Could not checkout the develop branch.
      Please make sure you don't have any uncommitted changes in the current branch.
      EOERROR
      exit_with_errors(error_message) unless $CHILD_STATUS.exitstatus.zero?
    end

    private

    attr_reader :pull_request_id, :release_branch, :backport_branch, :working_dir

    def create_backport_branch!
      `git checkout #{release_branch}`
      `git checkout -b #{backport_branch}`

      error_message = <<-EOERROR
      Branch already exists locally.
      Delete it with 'git branch -D #{backport_branch}' and rerun the script.
      EOERROR
      exit_with_errors(error_message) unless $CHILD_STATUS.exitstatus.zero?
    end

    def cherrypick_commit!(sha_commit)
      return unless sha_commit

      puts "Cherrypicking commit #{sha_commit}"
      `git cherry-pick #{sha_commit}`
      unless $CHILD_STATUS.exitstatus.zero?
        puts "Resolve the cherrypick conflict manually and exit your shell to keep with the process."
        system ENV.fetch("SHELL")
      end
    end

    def push_backport_branch!
      if `git diff #{backport_branch}..#{release_branch}`.empty?
        self.class.checkout_develop

        error_message = <<-EOERROR
        Nothing to push to remote server.
        It was probably merged already or the cherry-pick was aborted.
        EOERROR
        exit_with_errors(error_message)
      else
        puts "Pushing branch #{backport_branch} to #{remote}"
        `git push #{remote} #{backport_branch}`
      end
    end

    def remote
      `git remote -v | grep -e 'decidim/decidim\\([^ ]*\\) (push)' | sed 's/\\s.*//'`.strip
    end

    def sha_commit_to_backport
      `git log --format=oneline | grep "(##{pull_request_id})"`.split.first
    end

    def exit_if_unstaged_changes
      return if `git diff`.empty?

      error_message = <<-EOERROR
      There are changes not staged in your project.
      Please commit your changes or stash them.
      EOERROR
      exit_with_errors(error_message)
    end

    def exit_with_errors(message)
      puts message
      exit 1
    end
  end
end
