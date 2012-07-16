require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Exvo < OmniAuth::Strategies::OAuth2

      option :name, 'exvo'

      option :client_options, {
        :site => 'https://auth.exvo.com',
        :token_url => '/oauth/access_token'
      }

      def request_phase
        %w(scope x_sign_up).each do |param|
          options[:authorize_params][param.to_sym] = request[param] if request[param]
        end
        super
      end

      def callback_phase
        set_failure_handler
        super
      end

      def callback_key
        '_callback'
      end

      def callback_url
        if interactive?
          super
        else
          super + "?" + Rack::Utils.build_query(callback_key => request[callback_key])
        end
      end

      def interactive?
        !non_interactive?
      end

      def non_interactive?
        !!request[callback_key]
      end

      uid { raw_info['id'] }

      info do
        {
          'nickname' => raw_info['nickname'],
          'email' => raw_info['email']
        }
      end

      extra do
        {
          :raw_info => raw_info
        }
      end

      def raw_info
        access_token.options[:mode] = :query
        access_token.options[:param_name] = :access_token
        @raw_info ||= access_token.get('/user.json').parsed
      end

      def set_failure_handler
        OmniAuth.config.on_failure =
          if interactive?
            Proc.new do |env|
              message_key = env['omniauth.error.type']
              new_path = "#{env['SCRIPT_NAME']}#{OmniAuth.config.path_prefix}/failure?message=#{message_key}"
              [302, { 'Location' => new_path, 'Content-Type'=> 'text/html' }, []]
            end
          else
            OmniAuth.config.on_failure = Proc.new do |env|
              [401, { 'Content-Type' => 'application/javascript' }, [MultiJson.encode(:error => env['omniauth.error.type'])]]
            end
          end
      end
    end
  end
end
