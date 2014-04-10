module VagrantPlugins
  module ProxyConf
    module Cap
      # Utility methods for capabilities
      module Util
        # Returns path to the command on the machine, or false if it's not found
        def self.which(machine, cmd)
          path = false
          status = machine.communicate.execute(
            "which #{cmd}", error_check: false) do |type, data|
              # search for the command to work around `ssh.pty = true`
              path = data.chomp if type == :stdout && data =~ /#{cmd}$/
            end
          status == 0 && path
        end
      end
    end
  end
end
