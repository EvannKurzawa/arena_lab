# The login form can take longer than PEMK's 30-second pre-auth socket lifetime.
# Open a fresh connection AFTER typing, before sending an unauthenticated login
# or registration. Keep the same NetClient object used by the rest of PEMK.
# Authenticated resume/gameplay requests retain their existing connection.
if defined?(PEMK::Auth)
  module ArenaDemo
    module FreshLoginConnection
      def send_and_wait(client, message, types, timeout = PEMK::Config::LOGIN_TIMEOUT)
        if !PEMK::Auth.logged_in? && [:register, :login].include?(message[:type])
          PEMK.log("auth: refreshing connection before account request")
          client.close
          return nil unless client.connect
        end
        super(client, message, types, timeout)
      end
    end
  end
  unless PEMK::Auth.singleton_class.ancestors.include?(ArenaDemo::FreshLoginConnection)
    PEMK::Auth.singleton_class.prepend(ArenaDemo::FreshLoginConnection)
  end
end
