require 'test_helper'
require 'rake'

class VersionsTaskTest < Minitest::Test
  def test_running_task
    in_tmp_dir do
      `touch rails.gemspec`
      TDoc::VersionsTask.new
      Rake::Task['tdoc:versions'].execute

      versions = ['5.1.5', '4.2.7', '2.3.0']

      content = File.read('versions.json')
      assert_equal versions.to_json, content.rstrip
    end
  end

  def test_running_task_with_minimum
    in_tmp_dir do
      `touch rails.gemspec`
      TDoc::VersionsTask.new('3.0.0')
      Rake::Task['tdoc:versions'].execute

      versions = ['5.1.5', '4.2.7']

      content = File.read('versions.json')
      assert_equal versions.to_json, content.rstrip
    end
  end
end
