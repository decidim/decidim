# frozen_string_literal: true
# A collection of methods to help dealing with processes menu links.
module ProcessesMenuLinksHelpers
  # Clicks a link in the submenu of a participatory process navigation.
  #
  # text - a String with the name of the link that will be clicked
  def click_processes_menu_link(text)
    within ".secondary-nav--subnav" do
      click_link text
    end
  end
end
