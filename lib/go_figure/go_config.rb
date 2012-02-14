require 'nokogiri'
require 'erb'

module GoFigure
  class GoConfig
    attr_accessor :original_md5
    attr_reader   :original_xml

    def initialize(options = {})
      @original_md5 = options[:md5]
      @original_xml = options[:xml]
      @doc = Nokogiri.XML(@original_xml, nil, 'utf-8')
    end

    def add_pipeline(git_url, working_dir)
      @doc.root.xpath('pipelines').remove
      agents = @doc.root.xpath('agents')

      if agents.any?
        agents.before(pipeline_template(git_url, working_dir))
      else
        @doc.root << pipeline_template(git_url, working_dir)
      end

      @doc = Nokogiri.XML(@doc.to_s) do |config|
        config.default_xml.noblanks
      end
    end

    def pipeline_template(git_url, working_dir)
      template = ERB.new(File.read(File.expand_path('../../go-pipelines.xml.erb', __FILE__)))
      template.result(PipelineConfig.new(git_url, working_dir).get_binding)
    end

    def xml_content
      @doc.to_s
    end

    class PipelineConfig
      def initialize(git_url, working_dir)
        @git_url = git_url
        @working_dir = working_dir
      end

      def get_binding
        binding
      end
    end

  end
end
