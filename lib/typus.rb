# coding: utf-8

module Typus

  # Define the application name.
  mattr_accessor :admin_title
  @@admin_title = "Typus"

  # Define a subtitle
  mattr_accessor :admin_sub_title
  @@admin_sub_title = <<-CODE
<a href="http://intraducibles.com/projects/typus">Typus</a> is the effortless backend interface for <a href="http://rubyonrails.org/">Ruby on Rails</a> applications.<br />
Developed by <a href="http://intraducibles.com" rel="external">intraducibles.com</a>.</p>
  CODE

  # Authentication mechanism: none, basic, advanced
  mattr_accessor :authentication
  @@authentication = :advanced

  # Define the configuration folder.
  mattr_accessor :config_folder
  @@config_folder = "config/typus"

  # Define the username
  mattr_accessor :username
  @@username = "admin"

  # Define the password: Used as a default password and for the http 
  # authentication.
  mattr_accessor :password
  @@password = "columbia"

  # Define the default email.
  mattr_accessor :email
  @@email = nil

  # Define the file preview.
  mattr_accessor :file_preview
  @@file_preview = :typus_preview

  # Define the file thumbnail.
  mattr_accessor :file_thumbnail
  @@file_thumbnail = :typus_thumbnail

  # Defines the default relationship table.
  mattr_accessor :relationship
  @@relationship = "typus_users"

  # Defines the default master role.
  mattr_accessor :master_role
  @@master_role = "admin"

  # Defines the default user_class_name.
  mattr_accessor :user_class_name
  @@user_class_name = "TypusUser"

  # Defines the default user_fk.
  mattr_accessor :user_fk
  @@user_fk = "typus_user_id"

  class << self

    # Default way to setup typus. Run rails generate typus to create
    # a fresh initializer with all configuration values.
    def setup
      yield self
    end

    def root
      (File.dirname(__FILE__) + "/../").chomp("/lib/../")
    end

    def locales
      { "ca" => "Català", 
        "de" => "German", 
        "en" => "English", 
        "es" => "Español", 
        "fr" => "Français", 
        "hu" => "Magyar", 
        "pt-BR" => "Portuguese", 
        "ru" => "Russian" }
    end

    def applications
      Typus::Configuration.config.collect { |i| i.last["application"] }.compact.uniq.sort
    end

    # List of the modules of an application.
    def application(name)
      Typus::Configuration.config.collect { |i| i.first if i.last["application"] == name }.compact.uniq.sort
    end

    # Gets a list of all the models from the configuration file.
    def models
      Typus::Configuration.config.map { |i| i.first }.sort
    end

    def models_on_header
      models.collect { |m| m if m.constantize.typus_options_for(:on_header) }.compact
    end

    # List of resources, which are tableless models.
    def resources
      Typus::Configuration.roles.keys.map do |key|
        Typus::Configuration.roles[key].keys
      end.flatten.sort.uniq.delete_if { |x| models.include?(x) }
    end

    # Gets a list of models under app/models
    def detect_application_models
      model_dir = Rails.root.join("app/models")
      Dir.chdir(model_dir) do
        models = Dir["**/*.rb"]
      end
    end

    def application_models
      detect_application_models.map do |model|
        class_name = model.sub(/\.rb$/,"").camelize
        klass = class_name.split("::").inject(Object) { |klass,part| klass.const_get(part) }
        class_name if klass < ActiveRecord::Base && !klass.abstract_class?
      end.compact
    end

    def user_class
      user_class_name.constantize
    end

    def reload!
      Typus::Configuration.roles!
      Typus::Configuration.config!
    end

    def boot!

      # Support extensions
      require "support/active_record"
      require "support/hash"
      require "support/object"
      require "support/string"

      # Typus configuration and resources configuration
      require "typus/configuration"
      require "typus/resource"

      # Typus routing
      require "typus/routes"

      # Typus Active Record extensions and mixins
      require "typus/active_record"
      require "typus/user"

      # Vendor
      require "vendor/paginator"

    end

  end

end
