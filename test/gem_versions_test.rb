require 'test_helper'

class GemVersionsTest < Minitest::Test
  def test_initialize_infers_name_from_present_gemspec
    in_tmp_dir do
      `touch rails.gemspec`
      gv = TDoc::GemVersions.new

      assert_equal 'rails', gv.gem_name
    end
  end

  def test_minimum_is_properly_comparable
    gv = TDoc::GemVersions.new('2.3.0')

    assert_equal Gem::Version.new('2.3.0'), gv.minimum
  end

  def test_versions
    in_tmp_dir do
      `touch rails.gemspec`

      gv = TDoc::GemVersions.new
      versions = ['5.1.5', '4.2.7', '2.3.0']

      assert_equal versions, gv.versions
    end
  end

  def test_versions_with_minimum
    in_tmp_dir do
      `touch rails.gemspec`

      gv = TDoc::GemVersions.new('3.0.0')
      versions = ['5.1.5', '4.2.7']

      assert_equal versions, gv.versions
    end
  end
end
