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
        create_backport_branch!
        cherrypick_commit!(sha_commit)
        push_backport_branch!
      end
    end

    def self.checkout_develop
      `git checkout develop`
    end

    private

    attr_reader :pull_request_id, :release_branch, :backport_branch, :working_dir

    def create_backport_branch!
      `git checkout #{release_branch}`
      `git checkout -b #{backport_branch}`
      exit_with_errors("Branch already exists locally. Delete it with 'git branch -D #{backport_branch}' and rerun the script.") unless $CHILD_STATUS.exitstatus.zero?
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
        exit_with_errors("Nothing to push to remote server. It was probably merged already or the cherry-pick was aborted.")
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

      exit_with_errors("There are changes not staged in your project. Please commit your changes or stash them.")
    end

    def exit_with_errors(message)
      puts message
      exit 1
    end
  end
end
