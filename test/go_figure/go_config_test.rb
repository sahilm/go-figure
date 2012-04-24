require 'test_helper'

module GoFigure
  class GoConfigTest < Test::Unit::TestCase

    def test_should_set_agent_registration_key_on_the_server
      xml = %Q{<?xml version="1.0" encoding="utf-8"?>
<cruise xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="cruise-config.xsd" schemaVersion="41">
  <server artifactsdir="artifacts">
    <license user="IS team">GPXIhwIOEcByXG95ib4RMxIUn73G+BklnEn/Om+s/lHBCNhbboXsDufdjnom&#xD;
7ZYFzs1hhlY1bRf044wu4y1pmKBe/E5OjA2TbK5PGm3pwOvzUYD/peudL5Gs&#xD;
q+Ia8uD2PBf1bBhoEoYSy9JSs5zTIlNtSc+rCCYkZq+Sn2p0lRHOUzZ0bdkh&#xD;
3K/dHYyA4PsB1FciCZCShTlJwyOhSrpQw4qpJ2YAHl9yQN+v0HTGG4QV3fXG&#xD;
ztJLMGIEmyUR3CSu7KYHZ17XcgUsCFwrgbB24LgWC/CZg8r1eqb4lBh5V11b&#xD;
MSyuoIPAZhmk7osFKHdJ3wlGfEIQf2bhl+op7u/VZQ==</license>
  </server>
</cruise>
}

      config = GoConfig.new(:xml => xml)
      config.set_auto_registration_key("foobar")
      assert config.xml_content =~ /<server.*agentAutoRegisterKey="foobar".*/
    end
    
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
