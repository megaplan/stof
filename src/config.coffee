module.exports =
  stof:
    # Timeout waiting element present or not present on page
    elementWait: 30000

    browser: 'firefox'

    # google chrome addition capabilities
    # e.g.
#    chromeOptions:
#      mobileEmulation:
#        deviceName: 'Google Nexus 5'
#      args: [
#        '--disable-web-security'
#      ]

    os: 'LINUX'

    # Browser window sizes
    windowWidth: 1280
    windowHeight: 1024

    # On error here will be stored screenshots
    screenshotsDir: 'target/test/screenshots/'

    # On error here will be stored browser console output
    logsDir: 'target/test/logs/'

    selenium:
      # URL to selenium server or hub. For example, http://127.0.0.1:8888/wd/hub
      server: ''

      # Starts selenium server standalone if path is specified
      pathToJar: ''
      port: 4445
      # Standalone server start timeout
      startTimeout: 5000

    # Application path settings
    useSsl: false
    applicationHost: '127.0.0.1'
    port: 80