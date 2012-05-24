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
      @params = {}
    end

    def set_auto_registration_key(key)
      @doc.root.xpath('server').first["agentAutoRegisterKey"] = key
    end

    def set_pipeline(git_url, working_dir)
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

      @doc
    end

    def set_agents(agents_to_enable)
      existing_agents = @doc.root.xpath('agents/*')
      agents = "<agents>"
      agents_to_enable.inject(agents) do |str, agent|
        if not existing_agents.any? { |a| a.attr("uuid") == agent.uuid }
          str << %Q{<agent hostname="#{agent.hostname}" ipaddress="#{agent.ipaddress}" uuid="#{agent.uuid}"/>}
        end
      end
      agents << "</agents>"
      @doc.root << agents
    end

    def pipeline_template(git_url, working_dir)
      template = ERB.new(File.read(File.expand_path('../../go-pipelines.xml.erb', __FILE__)))
      template.result(PipelineConfig.new(git_url, working_dir, @params).get_binding)
    end

    def xml_content
      @doc.to_s
    end

    def set_rspec
      @params[:rspec] = true
    end

    def set_test_unit
      @params[:test_unit] = true
    end

    class PipelineConfig
      def initialize(git_url, working_dir, params)
        @git_url = git_url
        @working_dir = working_dir
        @params = params
      end

      def get_binding
        binding
      end
    end
  end

  class Agent < Struct.new(:hostname, :ipaddress, :uuid)
  end

end
