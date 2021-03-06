#!/usr/bin/env ruby

gem "buildr","1.3.3"
require "buildr"

# The goal of this script is to
#
# [1] create a release of tomcat+tempo+ode that can run out of the box
# [2] create a release of liferay+tempo+ode that can run out of the box
# [3] create a release of liferay+ui or tomcat+ui that connects to a standalone server, with or without opensso
# [4] create a set of files that can be expanded into a liferay server to configure ui-fw
# [5] create an OpenSSO standalone bundle
#
# Created: 2009-03-04
#
# Author: Nico: nico at intalio dot com

# monkey patching to allow buildr to run without a buildfile (since buildr 1.3.3)
class Buildr::Application 
  def settings
    @settings ||= Settings.new(self) 
  end 
end

OPENSSO_SERVER = "com.sun.opensso:server:war:8.0"

# loading repositories, dependencies files to locate artifacts
@@script_folder = File.dirname(File.expand_path("#{$0}"))
load "#{@@script_folder}/../build/repositories.rb"
load "#{@@script_folder}/../build/dependencies.rb"
load "#{@@script_folder}/../scripts/lib/build_support.rb"
load "#{@@script_folder}/../scripts/lib/bundle_servers.rb"
load "#{@@script_folder}/../scripts/lib/bundle_opensso.rb"
load "#{@@script_folder}/../scripts/lib/bundle_standalone.rb"
load "#{@@script_folder}/../scripts/config.rb"
TEMPO_SVN="#{@@script_folder}/../.."
Dir.chdir check_folder BUILD_CONFIG[:directory]

class TempoBuilder  
  include BuildActivate
  include Buildr

  def build cconfig, show_steps=false
    @config=cconfig
    @show_steps = show_steps

    # Create a standalone opensso server
    # opensso server 8.0 needs tomcat6
    activate_step [BuildMode::TOMCAT6,BuildMode::OPENSSO_SERVER], "Creating OpenSSO Bundle" do
      install_tomcat6 "tomcat-sso"
      install_opensso

      set_tomcat_ports ({"8005"=>"7005","8080"=>"7080", "8443"=>"7443", "8009"=> "7009"})
    end

    # TODO: finish this
    activate_step [BuildMode::LIFERAY], "Installing Liferay" do
      @@server_folder = download_unzip(BUILD_URI[:liferay][BUILD_CONFIG[:liferay]])
    end
    
    activate_step [BuildMode::TOMCAT], "Downloading tomcat" do
      install_tomcat
    end

    # this creates a full tomcat5 build, but does not include the uifw
    activate_step [BuildMode::BPMS], "Prepare standalone open source tomcat build" do
      install_tomcat5
      setup_axis_and_ode
      install_tempo_services
      install_tempo_webapps
      install_tmp
      install_absence_request
      copy_missing_lib
      clean_unused_files
      configure_tomcat
      generate_mysql_file
      setup_java_options
      chmod_sh_files
      copy_tempo_config_files
    end

    # copy security service configuration for opensso/ldap
    activate_step [BuildMode::BPMS,BuildMode::OPENSSO], "Customize tomcat build for opensso" do
      copy_tempo_config_file("securityConfig-opensso.xml", "securityConfig.xml")
      # opensso-ldap should be already copied
    end

    # this creates a tomcat6 build with ui-fw
    activate_step [BuildMode::UIFW,BuildMode::TOMCAT6], "Prepare remote open source tomcat build" do
      install_tomcat6 "tempo-remote"

      copy_tempo_config_files("tempo-ui-fw*")
      copy_tempo_config_files("tempo-formmanager.xml")
      replace_all_with_map_in_folder({"localhost:8080"=>"bpms.tempo.com:8080", "127.0.0.1:8080"=>"bpms.tempo.com:8080"}, "#{@@server_folder}/var/config")

      set_tomcat_ports ({"8005"=>"9005","8080"=>"9080", "8443"=>"9443", "8009"=> "9009"})

      options = "-XX:MaxPermSize=256m -server"
      options << " -Dfile.encoding=UTF-8"
      options << " -Xms128m -Xmx1024m"
      options << " -Dorg.intalio.tempo.configDirectory=$CATALINA_HOME/var/config"
      setenv "#{@@server_folder}/bin", options

      clean_unused_files
      chmod_sh_files
    end

    # this install the uifw war file
    activate_step [BuildMode::UIFW], "Adding the task list webapp" do 
      install_tempo_uifw
    end

    # add the configuration for ui-fw so that it can use opensso
    activate_step [BuildMode::UIFW,BuildMode::REMOTE,BuildMode::OPENSSO], "Configuring task list for opensso" do
      enable_opensso_in_uifw
    end
    
    activate_step [BuildMode::TOMCAT6, BuildMode::AGENT], "Installing OpenSSO Agent" do
      setup_opensso_tomcat6_agent
    end

    # zip the resulting @@server_folder
    activate_step [BuildMode::ZIP], "Zip build release" do
      compress(@@server_folder) if @@server_folder and File.exist? @@server_folder
    end
  end
end

tb = TempoBuilder.new
tb.build BUILD_CONFIG


