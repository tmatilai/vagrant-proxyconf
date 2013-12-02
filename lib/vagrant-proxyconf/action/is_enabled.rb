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

        def plugin_enabled?(config)
          config.enabled != false && config.enabled != ''
        end
      end
    end
  end
end
