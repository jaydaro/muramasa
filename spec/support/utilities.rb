module AutomationFramework
  class Utilities
    include Capybara::DSL
    include Capybara::RSpecMatchers
    include ::RSpec::Matchers
    OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

    def env
      ENV.fetch('APP_ENV', 'qa')
    end

    def sauce
      if ENV['USESAUCE']
        @sauce = true
      else
        @sauce = false
      end
    end

    def url(app)
      ENV["#{app.upcase}_URL"]
    end

    def user(app)
      ENV["#{app.upcase}_USER"]
    end

    def pass(app)
      ENV["#{app.upcase}_PASS"]
    end

    def launch_app(url)
      visit url
      web_status_code(url)
    end

    def web_status_code(url)
      sleep(2)
      res = Net::HTTP.get_response(URI(url))
      for i in 0..9
        if res.code == '200' || res.code == '302' || res.code == '301'
          break
        elsif i == 9
          abort("Website is getting a #{res.code}")
        else
          puts res.code
          page.visit url
        end
      end
    end

    def wait(element, time)
      wait = Selenium::WebDriver::Wait.new :timeout => time
      wait.until { find(element) }
    end

    def browser_back
      page.driver.go_back
    end

    def switch_to_newly_opened_window
      page.driver.browser.switch_to.window(page.driver.browser.window_handles.last)
    end

    def close_all_windows
      count = page.driver.browser.window_handles.length
      while count > 1
        page.driver.browser.close
        switchtonewlyopenedwindow
        count -= 1
      end
    end

    def verify_page_content(content)
      expect(page).to_not have_content('HTTP Status')
      expect(page.body).to have_content(content)
    end

    def switch_windows(window_title)
      within_window(-> {page.title == window_title})
    end

    def close_current_window
      page.driver.browser.switch_to.window(page.driver.browser.window_handles.last)
      page.execute_script 'window.close();'
      page.driver.browser.switch_to.window(page.driver.browser.window_handles.first)
    end

    def click_ok_msgbox
      page.driver.browser.switch_to.alert.accept
    end

    def scroll(scroll_position)
      page.execute_script "window.scrollBy(0,#{scroll_position})"
    end

    def is_content_visible(content)
      page.body.include?(content)
    end

    def is_checked(obj, attribute = 'name')
      page.find("[#{attribute}^='#{obj}']").checked?
    end

    def check(obj, attribute = 'name')
      return unless is_checked(obj) == false
      page.find("[#{attribute}^='#{obj}']").click
    end

    def uncheck(obj, attribute = 'name')
      return unless is_checked(obj) == true
      page.find("[#{attribute}^='#{obj}']").click
    end

    def log(msg, severity = 'info')
        if @log.respond_to?(:level) == false
            @log = Logger.new 'logger.log'
            self.setup_log_level(self.get_data_from_config_file('log_level'))
        end

        case severity
            when 'progname'
            @log.progname = msg
            when 'debug'
            @log.debug msg
            when 'info'
            @log.info msg
            when 'warn'
            @log.warn msg
            when 'error'
            @log.error msg
            when 'fatal'
            @log.fatal msg
        end
        puts msg
    end

    def get_data_from_config_file(property_name)
        config = YAML.load(File.read(File.path 'spec/support/config.yml'))
        config[property_name]
    end

    def setup_log_level(log_level)
        case log_level
            when 'info'
            @log.level = Logger::INFO
            when 'debug'
            @log.level = Logger::DEBUG
            when 'warn'
            @log.level = Logger::WARN
            when 'error'
            @log.level = Logger::ERROR
            when 'fatal'
            @log.level = Logger::FATAL
        end
    end
  end
end
