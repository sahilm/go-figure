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

    def test_should_set_the_rspec_pipeline_if_configured
      xml = %Q{<?xml version="1.0" encoding="utf-8"?>
          <cruise />
      }

      config = GoConfig.new(:xml => xml)
      config.set_rspec
      config.set_pipeline('http://git.example.com/my_project/atlas.git', 'atlas_rails')
      assert config.xml_content =~ /<arg>rake<\/arg>.\s*<arg>spec<\/arg>/m
    end

    def test_should_not_set_the_rspec_pipeline_if_not_configured
      xml = %Q{<?xml version="1.0" encoding="utf-8"?>
          <cruise />
      }

      config = GoConfig.new(:xml => xml)
      config.set_pipeline('http://git.example.com/my_project/atlas.git', 'atlas_rails')
      assert config.xml_content !~ /<arg>rake<\/arg>.\s*<arg>spec<\/arg>/m
    end

    def test_should_set_the_test_unit_pipeline_if_configured
      xml = %Q{<?xml version="1.0" encoding="utf-8"?>
          <cruise />
      }

      config = GoConfig.new(:xml => xml)
      config.set_test_unit
      config.set_pipeline('http://git.example.com/my_project/atlas.git', 'atlas_rails')
      assert config.xml_content =~ /<arg>rake<\/arg>.\s*<arg>test<\/arg>/m
    end

    def test_should_not_set_the_test_unit_pipeline_if_not_configured
      xml = %Q{<?xml version="1.0" encoding="utf-8"?>
          <cruise />
      }

      config = GoConfig.new(:xml => xml)
      config.set_pipeline('http://git.example.com/my_project/atlas.git', 'atlas_rails')
      assert config.xml_content !~ /<arg>rake<\/arg>.\s*<arg>test<\/arg>/m
    end

    def test_should_link_the_db_yml_to_a_controlled_db_yml
      xml = %Q{<?xml version="1.0" encoding="utf-8"?>
          <cruise />
      }

      config = GoConfig.new(:xml => xml)
      config.set_pipeline('http://git.example.com/my_project/atlas.git', 'atlas_rails')
      assert config.xml_content =~ /<exec command="\/bin\/ln">.\s*<arg>-sf<\/arg>.\s*<arg>\/etc\/go_saas\/database.yml<\/arg>.\s*<arg>config\/database.yml<\/arg>/m
    end

    def assert_pipeline_template(xml)
      config = GoConfig.new(:xml => xml)
      config.set_pipeline('http://git.example.com/my_project/atlas.git', 'atlas_rails')
      assert config.xml_content =~ %r{<pipelines group="defaultGroup">}
      assert config.xml_content =~ %r{<git autoUpdate="false" url="http://git.example.com/my_project/atlas.git"/>}
    end

  end
end
