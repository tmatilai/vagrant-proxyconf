module VagrantPlugins
  module ProxyConf
    module Config
      # Configuration key specifications
      class Key
        # @return [Symbol] the configuration key name
        attr_reader :name

        # @return [String, nil] the default value for the key
        attr_reader :default

        # @return [String, nil] the environment variable name
        attr_reader :env_var

        # @param name [Symbol, String] the key name
        # @param opts [Hash] optional key properties
        # @option opts [String, nil] :default (nil) the default value
        # @option opts [String, nil] :env_var (nil) the environment variable
        #   that overrides the configuration
        def initialize(name, opts = {})
          @name    = name.to_sym
          @default = opts[:default]
          @env_var = opts[:env_var]
        end

        # @yield if environment variable is not specified or set
        # @yieldparam default [String, nil] the {#default} value of the key
        # @yieldreturn [String, nil] the default value to be returned
        # @return [String] the value from the environment variable or the
        #   return value of the block or {#default}
        def value_from_env_var
          if env_var && ENV.key?(env_var)
            ENV[env_var]
          elsif block_given?
            yield default
          else
            default
          end
        end
      end
    end
  end
end
