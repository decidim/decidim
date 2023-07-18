# frozen_string_literal: true

require "shellwords"
require "English"

module Decidim
  # Handles the backport of a given pull request to a branch
  # Uses the git commnad line client
  class GitBackportManager
    # @param pull_request_id [String] the ID of the pull request that we want to backport
    # @param release_branch [String] the name of the branch that we want to backport to
    # @param backport_branch [String] the name of the branch that we want to create
    # @param working_dir [String] current working directory. Useful for testing purposes
    # @param exit_with_unstaged_changes [Boolean] wheter we should exit cowardly if there is any unstaged change
    def initialize(pull_request_id:, release_branch:, backport_branch:, working_dir: Dir.pwd, exit_with_unstaged_changes: false)
      @pull_request_id = pull_request_id
      @release_branch = release_branch
      @backport_branch = sanitize_branch(backport_branch)
      @working_dir = working_dir
      @exit_with_unstaged_changes = exit_with_unstaged_changes
    end

    # Handles all the different tasks involved on a backport with the git command line utility
    # It does the following tasks:
    # * Creates a branch based on a release branch
    # * Apply a commit to this branch
    # * Push it to the remote repository
    #
    # @return [void]
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
        clean_commit_message!
        push_backport_branch!
      end
    end

    # Switch to the develop branch
    # In case that it cannot do that, exits
    #
    # @return [void]
    def self.checkout_develop
      `git checkout develop`

      error_message = <<-EOERROR
      Could not checkout the develop branch.
      Please make sure you do not have any uncommitted changes in the current branch.
      EOERROR
      exit_with_errors(error_message) unless $CHILD_STATUS.exitstatus.zero?
    end

    private

    attr_reader :pull_request_id, :release_branch, :backport_branch, :working_dir

    # Create the backport branch based on a release branch
    # Checks that this branch does not exist already, if it does then exits
    #
    # @return [void]
    def create_backport_branch!
      `git checkout #{release_branch}`

      diff_count = `git rev-list HEAD..#{remote}/#{release_branch} --count`.strip.to_i
      `git pull #{remote} #{release_branch}` if diff_count.positive?
      `git checkout -b #{backport_branch}`

      error_message = <<-EOERROR
      Branch already exists locally.
      Delete it with 'git branch -D #{backport_branch}' and rerun the script.
      EOERROR
      exit_with_errors(error_message) unless $CHILD_STATUS.exitstatus.zero?
    end

    # Cherrypick a commit from another branch
    # Apply the changes introduced by some existing commits
    # Drops to a shell in case that it needs a manual conflict resolution
    #
    # @return [void]
    def cherrypick_commit!(sha_commit)
      return unless sha_commit

      puts "Cherrypicking commit #{sha_commit}"
      `git cherry-pick #{sha_commit}`

      unless $CHILD_STATUS.exitstatus.zero?
        puts "Resolve the cherrypick conflict manually and exit your shell to keep with the process."
        system ENV.fetch("SHELL")
      end
    end

    # Clean the commit message to remove the pull request ID of the last commit
    # This is mostly cosmetic, but if we don´t do this, we will have the two IDs on the final commit:
    # the ID of the original PR and the id of the backported PR.
    #
    # @return [void]
    def clean_commit_message!
      message = `git log --pretty=format:"%B" -1`
      message = message.lines[0].gsub!(/ \(#[0-9]+\)$/, "").concat(*message.lines[1..-1])
      message.gsub!('"', '"\""') # Escape the double quotes for bash as they are the message delimiters

      `git commit --amend -m "#{message}"`
    end

    # Push the branch to a git remote repository
    # Checks that there is actually something to push first, if not then it exits.
    #
    # @return [void]
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

    # The name of the git remote repository in the local git repository configuration
    # Most of the times this would be origin or upstream.
    #
    # @return [String] the name of the git repository
    def remote
      `git remote -v | grep -e 'decidim/decidim\\([^ ]*\\) (push)' | sed 's/\\s.*//'`.strip
    end

    # The SHA1 commit to backport
    # It needs to have a pull_request_id associated in the commit message
    #
    # @return [String] the SHA1 commit
    def sha_commit_to_backport
      `git log --format=oneline | grep "(##{pull_request_id})"`.split.first
    end

    # Replace all the characters from the user supplied input that are uncontrolled
    # and could generate a command line injection
    #
    # @return [String] the sanitized backport_branch
    def sanitize_branch(backport_branch)
      Shellwords.escape(backport_branch.gsub(%r{[^0-9a-z/-]}i, ""))
    end

    # Exit the script execution if there are any unstaged changes
    #
    # @return [void]
    def exit_if_unstaged_changes
      return if `git diff`.empty?

      error_message = <<-EOERROR
      There are changes not staged in your project.
      Please commit your changes or stash them.
      EOERROR
      exit_with_errors(error_message)
    end

    # Exit the script execution with a message
    #
    # @return [void]
    def exit_with_errors(message)
      puts message
      exit 1
    end
  end
end
