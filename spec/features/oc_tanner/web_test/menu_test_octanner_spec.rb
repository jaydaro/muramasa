require 'spec_helper'
app = AutomationFramework::Application.new
test_name = 'Open all OC Tanner Website mobile menu links'

feature test_name.to_s, sauce: app.sauce do
  scenario test_name.to_s, type: 'acceptance', broken: false,
                           dev: true, qa: true, prod: true do

    app.launch_app(app.url('OCT'))
    app.oct_landing_page.click_link(id:'mobile-nav-link')
    menu_links = app.oct_landing_page.find_by_id('mobile-nav-container')
                .all('a')
                .map { |anchor| anchor[:href] }

    $menu_links = []
    menu_links.each_with_index do |link, index|
      visit(link)
      app.web_status_code(link)
      $menu_links << link
      puts "index #{index}: #{link} did resolve with valid status code"
    end
    app.close_all_windows
  end
end
