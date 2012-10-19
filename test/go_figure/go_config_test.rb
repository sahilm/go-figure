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

    def test_should_set_the_jasmine_headless_webkit_stage_if_configured
      xml = %Q{<?xml version="1.0" encoding="utf-8"?>
          <cruise />
      }

      config = GoConfig.new(:xml => xml)
      config.set_jasmine_headless_webkit
      config.set_ruby('/usr/bin/ruby')
      config.set_pipeline('http://git.example.com/my_project/atlas.git', 'atlas_rails')

      assert config.xml_content.include? %Q{<stage name="Functionals">}
      assert config.xml_content.include? %Q{<variable name="DISPLAY">}
      assert config.xml_content.include? %Q{<arg>/usr/bin/ruby -S bundle exec rake --trace jasmine:headless</arg>}
      assert config.xml_content.include? %Q|<arg>Xvfb ${DISPLAY} &gt; .zeroci.xvfb.log 2&gt;&amp;1 &amp;</arg>|
        assert config.xml_content.include? %Q{<arg>ps aux | grep Xvfb | grep ${DISPLAY} | grep -v grep | awk '{print $2}' | xargs -I PID kill -9 PID || true</arg>}

      config = GoConfig.new(:xml => xml)
      config.set_ruby('/usr/bin/ruby')
      config.set_pipeline('http://git.example.com/my_project/atlas.git', 'atlas_rails')
      assert_false config.xml_content.include? %Q{<stage name="BrowserTests">}
      assert_false config.xml_content.include? %Q{<variable name="DISPLAY">}
      assert_false config.xml_content.include? %Q{<arg>/usr/bin/ruby -S bundle exec rake --trace jasmine:headless</arg>}
      assert_false config.xml_content.include? %Q|<arg>Xvfb ${DISPLAY} &gt; .zeroci.xvfb.log 2&gt;&amp;1 &amp;</arg>|
      assert_false config.xml_content.include? %Q{<arg>ps aux | grep Xvfb | grep ${DISPLAY} | grep -v grep | awk '{print $2}' | xargs -I PID kill -9 PID || true</arg>}
    end

    def test_should_set_the_rspec_pipeline_if_configured
      xml = %Q{<?xml version="1.0" encoding="utf-8"?>
          <cruise />
      }

      config = GoConfig.new(:xml => xml)
      config.set_rspec
      config.set_ruby('/usr/bin/ruby')
      config.set_pipeline('http://git.example.com/my_project/atlas.git', 'atlas_rails')
      assert config.xml_content =~ %r{<arg>/usr/bin/ruby -S bundle exec rake --trace spec</arg>}
    end

    test "should create the heroku deploy stage if configured" do
      xml = %Q{<?xml version="1.0" encoding="utf-8"?>
          <cruise />
      }
      config = GoConfig.new(:xml => xml)
      config.set_heroku_deploy
      config.set_ruby('/usr/bin/ruby')
      config.set_pipeline('http://git.example.com/my_project/atlas.git', 'atlas_rails')
      assert config.xml_content =~ %r{<arg>~/herokuSetup.sh /usr/bin/ruby</arg>}
      assert config.xml_content =~ %r{<arg>git push heroku master</arg>}
    end

    def test_should_not_set_the_rspec_pipeline_if_not_configured
      xml = %Q{<?xml version="1.0" encoding="utf-8"?>
          <cruise />
      }

      config = GoConfig.new(:xml => xml)
      config.set_pipeline('http://git.example.com/my_project/atlas.git', 'atlas_rails')
      assert config.xml_content !~ %r{rake spec}
    end

    def test_should_set_the_test_unit_pipeline_if_configured
      xml = %Q{<?xml version="1.0" encoding="utf-8"?>
          <cruise />
      }

      config = GoConfig.new(:xml => xml)
      config.set_test_unit
      config.set_ruby('/usr/bin/ruby')
      config.set_pipeline('http://git.example.com/my_project/atlas.git', 'atlas_rails')
      assert config.xml_content =~ %r{<arg>/usr/bin/ruby -S bundle exec rake --trace test</arg>}
    end

    def test_should_not_set_the_test_unit_pipeline_if_not_configured
      xml = %Q{<?xml version="1.0" encoding="utf-8"?>
          <cruise />
      }

      config = GoConfig.new(:xml => xml)
      config.set_pipeline('http://git.example.com/my_project/atlas.git', 'atlas_rails')
      assert config.xml_content !~ /<arg>rake<\/arg>.\s*<arg>test<\/arg>/m
    end


    test "should add an agent if there is no <pipelines> and no <agents/> tag" do
      xml = %Q{<?xml version="1.0" encoding="utf-8"?>
          <cruise />
      }

      config = GoConfig.new(:xml => xml)
      agents =[
               Agent.new('ho.st.name',  '12.0.0.121', 'some-uuid'),
               Agent.new('ho.st.name2', '12.0.0.122', 'some-uuid2'),
              ]

      config.set_agents(agents)

      doc = Nokogiri::XML(config.xml_content)

      agent_nodes = doc.root.xpath("agents/*")
      assert_equal 2, agent_nodes.size

      assert_agent(agents.first, agent_nodes.first)
      assert_agent(agents.last, agent_nodes.last)
    end

    test "should add an agent if there is a <pipeline> and no <agents/> tag" do
      xml = %Q{<?xml version="1.0" encoding="utf-8"?>
          <cruise >
            <pipelines group="1">
            </pipelines>
          </cruise>
      }

      config = GoConfig.new(:xml => xml)
      agents =[
               Agent.new('ho.st.name',  '12.0.0.121', 'some-uuid'),
               Agent.new('ho.st.name2', '12.0.0.122', 'some-uuid2'),
              ]

      config.set_agents(agents)

      doc = Nokogiri::XML(config.xml_content)

      assert_equal ["pipelines", "agents"], doc.root.xpath("*").map(&:name)
      assert_equal 1, doc.root.xpath('pipelines').count
    end

    test "should add an agent only if the agent is not present or disabled" do
      xml = %Q{<?xml version="1.0" encoding="utf-8"?>
          <cruise >
            <pipelines group="1">
            </pipelines>
          </cruise>
      }

      config = GoConfig.new(:xml => xml)
      agents =[
               Agent.new('ho.st.name',  '12.0.0.121', 'some-uuid'),
               Agent.new('ho.st.name2', '12.0.0.122', 'some-uuid2'),
              ]

      config.set_agents(agents)
      config.set_agents(agents)

      doc = Nokogiri::XML(config.xml_content)
      assert_equal 1, doc.root.xpath("agents").count
      agent_nodes = doc.root.xpath("agents/*")
      assert_equal 2, agent_nodes.count
    end

    test "should add post build hook if a build hook is set" do
      xml = %Q{<?xml version="1.0" encoding="utf-8"?>
          <cruise />
      }

      config = GoConfig.new(:xml => xml)
      config.set_ruby('/usr/bin/ruby')
      config.set_post_build_hook('rm -rf /')

      assert config.xml_content !~ /PostBuildHook/m
      assert config.xml_content !~ %r{<arg>/usr/bin/ruby -S bundle exec rake db:create db:migrate</arg>}
      assert config.xml_content !~ %r{<arg>/usr/bin/ruby -S bundle exec rm -rf /</arg>}
    end

    def assert_agent(agent, agent_node)
      assert_equal agent.hostname, agent_node.attr('hostname')
      assert_equal agent.ipaddress, agent_node.attr('ipaddress')
      assert_equal agent.uuid, agent_node.attr('uuid')
    end

    def test_should_link_the_db_yml_to_a_controlled_db_yml
      xml = %Q{<?xml version="1.0" encoding="utf-8"?>
          <cruise />
      }

      config = GoConfig.new(:xml => xml)
      config.set_database_required
      config.set_pipeline('http://git.example.com/my_project/atlas.git', 'atlas_rails')

      assert config.xml_content =~ /<exec command="\/bin\/ln">.\s*<arg>-sf<\/arg>.\s*<arg>\/etc\/go_saas\/database.yml<\/arg>.\s*<arg>config\/database.yml<\/arg>/m
    end

    def test_should_support_twist
      xml = %Q{<?xml version="1.0" encoding="utf-8"?>
          <cruise />
      }

      config = GoConfig.new(:xml => xml)
      config.set_ruby('/usr/bin/ruby')
      config.set_twist
      config.set_database_required
      config.set_pipeline('http://git.example.com/my_project/atlas.git', 'atlas_rails')

      assert config.xml_content.include? %Q{<variable name="DISPLAY">}
      assert config.xml_content.include? %Q{<arg>/usr/bin/ruby -S bundle exec rake --trace db:drop db:create db:migrate</arg>}
      assert config.xml_content.include? %Q{<arg>/usr/bin/ruby -S bundle exec rake --trace twist:run_tests</arg>}
      assert config.xml_content.include? %Q{<arg>/usr/bin/ruby -S bundle exec rake --trace twist:server:stop</arg>}
      assert config.xml_content.include? %Q{cp test/twist/src/twist.linux.properties test/twist/src/twist.properties}
      assert config.xml_content.include? %Q|<arg>Xvfb ${DISPLAY} &gt; .zeroci.xvfb.log 2&gt;&amp;1 &amp;</arg>|
      assert config.xml_content.include? %Q{<arg>ps aux | grep Xvfb | grep ${DISPLAY} | grep -v grep | awk '{print $2}' | xargs -I PID kill -9 PID || true</arg>}

  config = GoConfig.new(:xml => xml)
  config.set_ruby('/usr/bin/ruby')
  config.set_pipeline('http://git.example.com/my_project/atlas.git', 'atlas_rails')
  assert_false config.xml_content.include? %Q{<variable name="DISPLAY">}
  assert_false config.xml_content.include? %Q{<arg>/usr/bin/ruby -S bundle exec rake --trace db:drop db:create db:migrate</arg>}
      assert_false config.xml_content.include? %Q{<arg>/usr/bin/ruby -S bundle exec rake --trace twist:run_tests</arg>}
      assert_false config.xml_content.include? %Q{<arg>/usr/bin/ruby -S bundle exec rake --trace twist:server:stop</arg>}
      assert_false config.xml_content.include? %Q{cp test/twist/src/twist.linux.properties test/twist/src/twist.properties}
  assert_false config.xml_content.include? %Q|<arg>Xvfb ${DISPLAY} &gt; .zeroci.xvfb.log 2&gt;&amp;1 &amp;</arg>|
      assert_false config.xml_content.include? %Q{ps aux | grep Xvfb | grep ${DISPLAY} | grep -v grep | awk '{print $2}' | xargs -I PID kill -9 PID || true</arg>}
    end

    def assert_pipeline_template(xml)
      config = GoConfig.new(:xml => xml)
      config.set_pipeline('http://git.example.com/my_project/atlas.git', 'atlas_rails')
      assert config.xml_content =~ %r{<pipelines group="defaultGroup">}
      assert config.xml_content =~ %r{<git autoUpdate="false" url="http://git.example.com/my_project/atlas.git"/>}
    end

    def test_should_set_the_environment_variables
      xml = %Q{<?xml version="1.0" encoding="utf-8"?>
          <cruise />
      }

      config = GoConfig.new(:xml => xml)
      config.set_environment_variables({:key1 => :value1, :key2 => :value2})
      config.set_pipeline('http://git.example.com/my_project/atlas.git', 'atlas_rails')

      assert config.xml_content =~ /<environmentvariables>\s*<variable name="key1">\s*<value>value1<\/value>\s*<\/variable>.*<\/environmentvariables>/m
    end

  end
end
