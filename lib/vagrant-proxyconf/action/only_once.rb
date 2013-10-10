require_relative '../logger'

module VagrantPlugins
  module ProxyConf
    class Action
      # A middleware class that builds and runs the stack based on the
      # specified block, but only once.
      class OnlyOnce
        # @param opts [Hash] the options
        # @option opts [Boolean] :before (false) should the block be called
        #   before (instead of after) passing control to the next middleware
        def initialize(app, env, opts = {}, &block)
          raise ArgumentError, "A block must be given to OnlyOnce" if !block

          @app    = app
          @before = opts[:before]
          @block  = block
        end

        def call(env)
          @app.call(env) if !@before

          if env[@block]
            logger.info "Skipping repeated '#{@block}' stack"
          else
            logger.info "'#{@block}' stack invoked first time"
            env[@block] = true

            new_env = build_and_run_block(env)
            env.merge!(new_env)
          end

          @app.call(env) if @before
        end

        def recover(env)
          # Call back into our compiled application and recover it.
          @child_app.recover(env) if @child_app
        end

        private

        # @return [Log4r::Logger]
        def logger
          ProxyConf.logger
        end

        # Creates and runs a Builder based on the block given in initializer.
        #
        # @param env [Hash] the current environment
        # @return [Hash] the new environment
        def build_and_run_block(env)
          builder = Vagrant::Action::Builder.new
          @block.call(builder)
          @child_app = builder.to_app(env)
          Vagrant::Action::Runner.new.run(@child_app, env)
        end
      end
    end
  end
end
