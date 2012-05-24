module GoFigure
  module Version
    MAJOR = 0
    MINOR = 0
    PATCH = 11
    RELEASE = ENV['GO_PIPELINE_COUNTER']
    VERSION = [MAJOR, MINOR, PATCH, RELEASE].compact.join('.')
  end
end
