require_relative '../../lib/dev_mail_interceptor.rb'
ActionMailer::Base.register_interceptor(DevMailInterceptor) if Rails.env.development?