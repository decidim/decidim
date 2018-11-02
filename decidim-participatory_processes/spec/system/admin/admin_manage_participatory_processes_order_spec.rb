# frozen_string_literal: true

require "spec_helper"

describe "Admin sorts participatory process", type: :system do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }

  let!(:first_participatory_process) do
    create(
      :participatory_process,
      :with_steps,
      :published,
      :private_space,
      title: "AAAAAA",
      organization: organization,
      created_at: Time.current.ago(4.days)
    )
  end

  let!(:second_participatory_process) do
    create(
      :participatory_process,
      :with_steps,
      :published,
      title: "BBBBBB",
      organization: organization,
      created_at: Time.current.ago(1.day)
    )
  end

  let!(:third_participatory_process) do
    create(
      :participatory_process,
      :with_steps,
      :published,
      :promoted,
      title: "CCCCCC",
      organization: organization,
      created_at: Time.current.ago(2.days)
    )
  end

  let!(:fourth_participatory_process) do
    create(
      :participatory_process,
      :with_steps,
      :unpublished,
      title: "DDDDDD",
      organization: organization,
      created_at: Time.current.ago(3.days)
    )
  end

  let!(:participatory_processes) do
    [
      first_participatory_process,
      second_participatory_process,
      third_participatory_process,
      fourth_participatory_process
    ]
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_participatory_processes.participatory_processes_path
  end

  context "when ordering by title" do
    it "sorts elements in ASC order" do
      click_link "Title"

      participatory_processes.each_with_index do |participatory_process, index|
        within "tbody > tr:nth-child(#{index + 1})" do
          expect(page).to have_content participatory_process.title
        end
      end
    end

    it "sorts elements in DESC order" do
      double_click_link "Title"

      participatory_processes.to_a.reverse.each_with_index do |participatory_process, index|
        within "tbody > tr:nth-child(#{index + 1})" do
          expect(page).to have_content participatory_process.title
        end
      end
    end
  end

  context "when ordering by higlighted" do
    it "sorts elements in ASC order" do
      click_link "Highlighted"

      within "tbody > tr:last-child" do
        expect(page).to have_content third_participatory_process.title
      end
    end
    it "sorts elements in DESC order" do
      double_click_link "Highlighted"

      within "tbody > tr:first-child" do
        expect(page).to have_content third_participatory_process.title
      end
    end
  end

  context "when ordering by created_at" do
    it "sorts elements in ASC order" do
      click_link "Created at"

      participatory_processes.each_with_index do |participatory_process, index|
        within "tbody > tr:nth-child(#{index + 1})" do
          expect(page).to have_content translated(participatory_process.created_at)
        end
      end
    end
    it "sorts elements in DESC order" do
      double_click_link "Created at"

      participatory_processes.each_with_index do |participatory_process, index|
        within "tbody > tr:nth-child(#{index + 1})" do
          expect(page).to have_content translated(participatory_process.created_at)
        end
      end
    end
  end

  context "when ordering by private" do
    it "sorts elements in ASC order" do
      click_link "Private"

      within "tbody > tr:last-child" do
        expect(page).to have_content first_participatory_process.title
      end
    end
    it "sorts elements in DESC order" do
      double_click_link "Private"

      within "tbody > tr:first-child" do
        expect(page).to have_content first_participatory_process.title
      end
    end
  end

  context "when ordering by published" do
    it "sorts elements in ASC order" do
      click_link "Published"

      within "tbody > tr:last-child" do
        expect(page).to have_content fourth_participatory_process.title
      end
    end
    it "sorts elements in DESC order" do
      double_click_link "Published"

      within "tbody > tr:first-child" do
        expect(page).to have_content fourth_participatory_process.title
      end
    end
  end
end
