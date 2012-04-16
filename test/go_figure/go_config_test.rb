require 'test_helper'

module GoFigure
  class GoConfigTest < Test::Unit::TestCase

    def test_should_set_pipeline_in_a_config_file_with_no_pipelines_and_no_agents
      assert_pipeline_template %Q{<?xml version="1.0" encoding="utf-8"?>
          <cruise />
      }
    end

    def test_should_set_pipeline_in_a_config_file_with_pipelines_and_no_agents

      assert_pipeline_template %Q{<?xml version="1.0" encoding="utf-8"?>
          <cruise>
            <pipelines group="1">
            </pipelines>

            <pipelines group="2">
            </pipelines>
          </cruise>
      }
    end

    def test_should_set_pipeline_in_a_config_file_with_no_pipelines_and_agents
      assert_pipeline_template %Q{<?xml version="1.0" encoding="utf-8"?>
          <cruise>
            <agents />
         </cruise>
      }
    end

    def test_should_set_pipelines_in_a_config_file_with_pipelines_and_agents
      assert_pipeline_template %Q{<?xml version="1.0" encoding="utf-8"?>
          <cruise>
            <pipelines group="1">
            </pipelines>

            <pipelines group="2">
            </pipelines>
             <agents />
          </cruise>
      }
    end


    def assert_pipeline_template(xml)
      config = GoConfig.new(:xml => xml)
      config.set_pipeline('http://git.example.com/my_project/atlas.git', 'atlas_rails')
      assert config.xml_content =~ %r{<pipelines group="defaultGroup">}
      assert config.xml_content =~ %r{<git autoUpdate="false" url="http://git.example.com/my_project/atlas.git"/>}
    end

  end
end
