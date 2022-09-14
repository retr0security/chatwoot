class ApplicationController < ActionController::Base
  include DeviseTokenAuth::Concerns::SetUserByToken
  include RequestExceptionHandler
  include Pundit::Authorization
  include SwitchLocale

  skip_before_action :verify_authenticity_token

  before_action :set_current_user, unless: :devise_controller?
  around_action :switch_locale
  around_action :handle_with_exception, unless: :devise_controller?

  private

  def set_current_user
    @user ||= current_user
    Current.user = @user
  end

  def pundit_user
    {
      user: Current.user,
      account: Current.account,
      account_user: Current.account_user
    }
  end

  def append_info_to_payload(payload)
    super
    case
      when payload[:status] == 200
        payload[:level] = "INFO"
      when payload[:status] == 302
        payload[:level] = "WARN"
      else
        payload[:level] = "ERROR"
    end
  end

end
