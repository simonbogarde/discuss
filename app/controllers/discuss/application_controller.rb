module Discuss
  class ApplicationController < ::ApplicationController
    before_action :discuss_current_user

    private
    def discuss_current_user
      current_user
    end
    helper_method :discuss_current_user

    def recipients
      discuss_recipients || User.all.reject { |u| u == discuss_current_user }
    end
    helper_method :recipients

    # For example `set_flash_message :notice, :trash_emptied`
    def set_flash_message(key, kind, options = {})
      message = find_message(kind, options)
      flash[key] = message if message.present?
    end

    def find_message(kind, options = {})
      I18n.t("discuss.#{controller_name}.#{kind}", options)
    end
  end
end
