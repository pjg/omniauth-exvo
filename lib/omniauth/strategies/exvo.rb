require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Exvo < OmniAuth::Strategies::OAuth2

      option :name, 'exvo'

      option :client_options, {
        :site => 'http://auth.exvo.local',
        :token_url => 'http://auth.exvo.local/oauth/access_token'
      }

      def request_phase
        options[:scope] = request["scope"] if request["scope"]
        options[:state] = request["state"] if request["state"]
        options[:x_sign_up] = request["x_sign_up"] if request["x_sign_up"]
        super
      end

      def callback_url
        # key = ExvoAuth::Config.callback_key
        key = '_callback'
        value = request[key]

        if value
          # non_interactive (JSON/JSONP)
          super + "?" + Rack::Utils.build_query(key => value)
        else
          # interactive
          super
        end
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
    end
  end
end
