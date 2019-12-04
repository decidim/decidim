# frozen_string_literal: true

shared_context "with admin filters" do
  # @param label: The aria-label in the LI tags to be hovered of the filter.
  # @param text_to_click: The text to click in the opened submenu of the filter.
  def visit_filtered_results(label, text_to_click)
    within ".filters__section" do
      find("li", text: "FILTER").hover
      find("li[aria-label=#{label}]").hover
      within("li[aria-label=#{label}") do
        find("a", text: text_to_click).click
      end
    end
  end

  def visit_filtered_results_by_search(text)
    within ".filters__section" do
      fill_in :q_id_or_title_cont, with: text
      find("*[type=submit]").click
    end
  end
end
