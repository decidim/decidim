# frozen_string_literal: true

require "decidim/releaser"

describe Decidim::Releaser do
  subject { described_class.new(token:, version_type:, exit_with_unstaged_changes:, working_dir: tmp_repository_dir) }

  let(:token) { "1234" }
  let(:version_type) { "patch" }
  let(:release_branch) { "release/0.99-stable" }
  let(:tmp_repository_dir) { "/tmp/decidim-releaser-test-#{rand(1_000)}" }
  let(:working_dir) { File.expand_path("../../..", __dir__) }
  let(:exit_with_unstaged_changes) { true }
  let(:decidim_version) { "0.99.0.rc1" }

  before do
    FileUtils.mkdir_p("#{tmp_repository_dir}/code")
    Dir.chdir("#{tmp_repository_dir}/code")
    `
      git init --initial-branch=develop .
      git config user.email "decidim_releaser@example.com"
      git config user.name "Decidim::Releaser test"

      touch a_file.txt && git add a_file.txt
      echo #{decidim_version} > .decidim-version && git add .decidim-version
      git commit -m "Initial commit (#1234)"

      git branch #{release_branch}
      git switch --quiet #{release_branch}
    `
  end

  after do
    Dir.chdir(working_dir)
    FileUtils.rm_r(Dir.glob(tmp_repository_dir))
  end

  describe "#branch" do
    it "returns the correct branch" do
      expect(subject.send(:branch)).to eq release_branch
    end
  end

  describe "#release_branch" do
    it "returns the correct branch" do
      expect(subject.send(:release_branch)).to eq release_branch
    end

    context "when we are not in a release branch" do
      it "raises an error" do
        `git switch --quiet develop`
        expect { subject.send(:release_branch) }.to raise_error(Decidim::Releaser::InvalidBranchError)
      end
    end
  end

  describe "#bump_decidim_version" do
    context "when it is a release candidate" do
      let(:decidim_version) { "0.99.0.rc1" }
      let(:version_type) { "rc" }

      it "changes the version number in the decidim version file" do
        version_number = File.read(".decidim-version").strip
        expect(version_number).to eq("0.99.0.rc1")

        subject.send(:bump_decidim_version)
        new_version_number = File.read(".decidim-version").strip

        expect(new_version_number).to eq("0.99.0.rc2")
      end
    end

    context "when it is a patch release" do
      let(:decidim_version) { "0.99.0" }
      let(:version_type) { "patch" }

      it "changes the version number in the decidim version file" do
        subject.send(:bump_decidim_version)
        new_version_number = File.read(".decidim-version").strip

        expect(new_version_number).to eq("0.99.1")
      end
    end
  end

  describe "#parsed_version_number" do
    context "when it is a dev version" do
      let(:version_number) { "1.2.3.dev" }

      it "parses the version number" do
        expect(subject.send(:parsed_version_number, version_number)).to eq({ major: 1, minor: 2, patch: 3 })
      end
    end

    context "when it is a release candidate version" do
      let(:version_number) { "1.2.3.rc1" }

      it "parses the version number" do
        expect(subject.send(:parsed_version_number, version_number)).to eq({ major: 1, minor: 2, patch: 3 })
      end
    end

    context "when it is a patch version" do
      let(:version_number) { "1.2.3" }

      it "parses the version number" do
        expect(subject.send(:parsed_version_number, version_number)).to eq({ major: 1, minor: 2, patch: 3 })
      end
    end
  end

  describe "#next_version_number_for_release_candidate" do
    context "when it is a dev version" do
      let(:version_number) { "0.1.0.dev" }

      it "returns the first release candidate" do
        expect(subject.send(:next_version_number_for_release_candidate, version_number)).to eq "0.1.0.rc1"
      end
    end

    context "when it is a release candidate version" do
      let(:version_number) { "0.1.0.rc1" }

      it "returns the correct next version number" do
        expect(subject.send(:next_version_number_for_release_candidate, version_number)).to eq "0.1.0.rc2"
      end
    end

    context "when it is a patch version" do
      let(:version_number) { "0.1.0" }

      it "raises an error" do
        expect { subject.send(:next_version_number_for_release_candidate, version_number) }.to raise_error(Decidim::Releaser::InvalidVersionTypeError)
      end
    end
  end

  describe "#next_version_number_for_patch_release" do
    context "when it is a dev version" do
      let(:version_number) { "0.1.0.dev" }

      it "returns the correct next version number" do
        expect { subject.send(:next_version_number_for_patch_release, version_number) }.to raise_error(Decidim::Releaser::InvalidVersionTypeError)
      end
    end

    context "when it is a release candidate version" do
      let(:version_number) { "0.1.0.rc1" }

      it "returns first patch number" do
        expect(subject.send(:next_version_number_for_patch_release, version_number)).to eq "0.1.0"
      end
    end

    context "when it is a patch version" do
      let(:version_number) { "0.1.0" }

      it "raises an error" do
        expect(subject.send(:next_version_number_for_patch_release, version_number)).to eq "0.1.1"
      end
    end
  end

  describe "#old_version_number" do
    let(:decidim_version) { "0.1.0" }

    it "returns the correct version number" do
      expect(subject.send(:old_version_number)).to eq "0.1.0"
    end
  end
end
