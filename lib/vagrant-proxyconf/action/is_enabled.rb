module VagrantPlugins
  module ProxyConf
    class Action
      # Action which checks if the plugin should be enabled
      class IsEnabled
        def initialize(app, env)
          @app = app
        end

        def call(env)
          env[:result] = plugin_enabled?(env[:machine].config.proxy)

          @app.call(env)
        end

        private

        def has_proxy_env_var?(var='HTTP_PROXY')
          var_not_in_env = ENV[var].nil? || ENV[var] == ''
          return false if var_not_in_env

          true
        end

        def plugin_disabled?(config)
          config.enabled == false || config.enabled == '' || config.enabled.nil? || config.enabled == {}
        end

        def plugin_enabled?(config)
          return false if plugin_disabled?(config)

          # check for existence of HTTP_PROXY and HTTPS_PROXY environment variables
          has_proxy_var = has_proxy_env_var?('HTTP_PROXY') || has_proxy_env_var?('HTTPS_PROXY')
          return false if has_proxy_var == false

          true
        end
      end
    end
  end
end
