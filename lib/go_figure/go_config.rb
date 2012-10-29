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
      new_agents = agents_to_enable.collect do |agent|
        %Q{<agent hostname="#{agent.hostname}" ipaddress="#{agent.ipaddress}" uuid="#{agent.uuid}"/>}
      end

      agents = "<agents>#{new_agents.join}</agents>"

      if existing_agents = @doc.root.xpath('agents')[0]
        existing_agents.replace(agents)
      else
        @doc.root << agents
      end
    end

    def pipeline_template(git_url, working_dir)
      template = ERB.new(File.read(File.expand_path('../../go-pipelines.xml.erb', __FILE__)))
      template.result(PipelineConfig.new(git_url, working_dir, @params).get_binding)
    end

    def xml_content
      @doc.to_s
    end

    def set_post_build_hook(post_build_hook)
      @params[:post_build_hook] = post_build_hook
    end

    def set_ruby(ruby)
      @params[:ruby] = ruby
      @params[:ruby_path] = ruby.gsub(/bin\/ruby$/, "bin") if ruby
    end

    def set_init(init)
      @params[:init] = init
    end

    def set_rspec
      @params[:rspec] = true
    end

    def set_test_unit
      @params[:test_unit] = true
    end

    def set_twist
      @params[:twist] = true
    end

    def set_database_required
      @params[:database_required] = true
    end

    def set_jasmine_headless_webkit
      @params[:jasmine] = true
    end

    def set_environment_variables(value)
      @params[:environment_variables] = value
    end

    def set_heroku_deploy
      @params[:heroku_deploy] = true
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
