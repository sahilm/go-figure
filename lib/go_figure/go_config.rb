module GoFigure
  class GoConfig
    attr_accessor :original_md5, :xml
    attr_reader   :original_xml

    def initialize(options = {})
      @original_md5 = options[:md5]
      @original_xml = options[:xml]
    end

  end
end
