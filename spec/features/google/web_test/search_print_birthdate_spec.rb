require 'spec_helper'
app = AutomationFramework::Application.new
test_name = 'Search Google, Print Mura Masa birthdate'

feature test_name.to_s, sauce: app.sauce do
  scenario test_name.to_s, type: 'acceptance', broken: false,
           dev: true, qa: true, prod: true do

    app.launch_app(app.url('GOOGLE'))
    app.google_landing_page.enter_search_text('Mura Masa')
    app.google_landing_page.click_search
    app.google_landing_page.click_link('Mura Masa - Wikipedia')
    birthdate = app.google_landing_page.all('tr')[3].find('td').text[0,12]
    puts birthdate

    app.close_all_windows
  end
end