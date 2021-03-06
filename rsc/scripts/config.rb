include BuildSupport
BuildSupport::BUILD_DEBUG = false

BUILD_CONFIG = {
  :directory => "../intalio",
  
  # build with ode, axis2, uifw
  #
  # :mode => [BuildMode::BPMS,BuildMode::UIFW],
  #
  
  # build with ode, axis2, *NO* uifw, and opensso support on the server side
  #
  # :mode => [BuildMode::BPMS,BuildMode::OPENSSO]
  #
  
  #
  # build the above and zip the resulting folder
  # :mode => [BuildMode::TOMCAT,BuildMode::UIFW,BuildMode::ZIP],
  
  # build with tomcat6 and uifw 
  #
  # :mode => [BuildMode::TOMCAT6,BuildMode::UIFW],
  #
  
  # build with tomcat6 and uifw, enable for opensso 
  #
  :mode => [BuildMode::REMOTE, BuildMode::TOMCAT6,BuildMode::UIFW,BuildMode::OPENSSO,BuildMode::AGENT ],
  #
  
  # build an opensso server
  #
  # :mode =>  [BuildMode::TOMCAT6,BuildMode::OPENSSO],
  #
  
  :ode => :v2_1_snapshot,
  :tomcat => :v5,
  :liferay => :v5_1_0,
  :alfresco => :v3_0,
  :tempo => {
    :core => "6.0.0.35-SNAPSHOT",
    :security => "1.0.0",
    :deploy => "1.0.0",
    :formManager => "6.0.0.35",
    :apacheds => "6.0.0.34",
    :cas => "6.0.0.34"
  }
}