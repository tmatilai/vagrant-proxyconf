require_relative 'key'

module VagrantPlugins
  module ProxyConf
    module Config
      # Helper module for Config classes.
      #
      # Handles mapping to environment variables, setting default values,
      # and constructing the configuration file stanza.
      module KeyMixin

        # Methods for the including class to specify and access the configuration keys.
        module ClassMethods
          # @!attribute [r] keys
          # @return [Array<Key>] the configuration keys for the class
          def keys
            @keys ||= []
          end

          # Defines a configuration key for the class.
          # Creates `attr_accessor` for the key name and adds a {Key} to {#keys}.
          # @param (see Key#initialize)
          # @option (see Key#initialize)
          def key(name, opts = {})
            self.class_eval { attr_accessor name }
            keys << Key.new(name, opts)
          end
        end

        # Extends the including class with {ClassMethods}
        def self.included(base)
          base.extend ClassMethods
        end

        # Initializes all keys to `UNSET_VALUE`
        def initialize
          super
          keys.each do |key|
            set(key, self.class::UNSET_VALUE)
          end
        end

        # Overrides values from specified environment variables, and sets them
        # to default values if no configuration was found
        def finalize!
          super
          keys.each { |key| set(key, resolve_value(key)) }
        end

        # @return [Boolean] true if any of the configuration keys has a non-nil value
        def enabled?
          keys.any? { |key| set?(key) }
        end

        # Returns the full configuration stanza
        # Calls {#config_for} for each key.
        #
        # @return [String]
        def to_s
          keys.map { |key| config_for(key, get(key)).to_s }.join
        end

        # Returns a configuration line/stanza for the specified key and value.
        # The returned line should include linefeed `\\n` if not empty.
        # The default implementations returns "<key>=<value>\\n".
        #
        # @param key [Key] the configuration key
        # @param value [String, nil] the configuration value
        # @return [#to_s] the configuration line(s)
        def config_for(key, value)
          "#{key}=#{value}\n"
        end

        private

        def keys
          self.class.keys
        end

        def key?(key)
          keys.any? { |k| k.name == key.name }
        end

        def get(key)
          send(key.name)
        end

        def set?(key)
          !get(key).nil?
        end

        def set(key, value)
          send(:"#{key.name}=", value)
        end

        def resolve_value(key)
          key.value_from_env_var do |default|
            value = get(key)
            value == self.class::UNSET_VALUE ? default : value
          end
        end
      end
    end
  end
end
