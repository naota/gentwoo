require 'rails/generators'
require 'rails/generators/migration'


module TwitterAuth
   module Generators
      class TwitterAuthGenerator < Rails::Generators::Base
        include Rails::Generators::Migration
        
        argument :auth_type, :type => :string, :default => "oauth", :banner => "authtype=oauth"
      
      
        def self.source_root
          @_twitter_auth_source_root ||= File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
        end
      
        
        def create_twitter_auth_setup
          migration_template 'migration.rb', 'db/migrate', :migration_file_name => 'twitter_auth_migration'
          template 'user.rb', File.join('app','models','user.rb')
          template 'twitter_auth.yml', File.join('config','twitter_auth.yml')
        end
        
        protected
        
        # Borrowed this from the DM generator
        def self.next_migration_number(dirname) #:nodoc:
            "%.3d" % (current_migration_number(dirname) + 1)
        end
     
     end
   end
end
