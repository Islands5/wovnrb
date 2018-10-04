require 'test_helper'

class DstSwappingTargetsCreatorTest < ActiveSupport::TestCase
  test 'run' do
    text_index = {
      '' => {
        'en' => [
          { 'data' => 'a<a>b</a>c' }
        ]
      }
    }

    UnifiedValues::DstSwappingTargetsCreator.new(text_index).run!
    assert_equal(%w[a b c], text_index['']['en'][0]['swapping_targets'])
  end

  test 'run_with_data_with_spaces' do
    text_index = {
      '' => {
        'en' => [
          { 'data' => ' a <a> b </a> c ' }
        ]
      }
    }

    UnifiedValues::DstSwappingTargetsCreator.new(text_index).run!
    assert_equal([' a ', ' b ', ' c '], text_index['']['en'][0]['swapping_targets'])
  end

  test 'run_with_data_stated_by_tag' do
    text_index = {
      '' => {
        'en' => [
          { 'data' => '<a>b</a>c' }
        ]
      }
    }

    UnifiedValues::DstSwappingTargetsCreator.new(text_index).run!
    assert_equal(['', 'b', 'c'], text_index['']['en'][0]['swapping_targets'])
  end

  test 'run_with_data_ended_by_tag' do
    text_index = {
      '' => {
        'en' => [
          { 'data' => 'a<a>b</a>' }
        ]
      }
    }

    UnifiedValues::DstSwappingTargetsCreator.new(text_index).run!
    assert_equal(['a', 'b', ''], text_index['']['en'][0]['swapping_targets'])
  end

  test 'run_with_data_with_no_content_inside_tag' do
    text_index = {
      '' => {
        'en' => [
          { 'data' => 'a<a></a>c' }
        ]
      }
    }

    UnifiedValues::DstSwappingTargetsCreator.new(text_index).run!
    assert_equal(['a', '', 'c'], text_index['']['en'][0]['swapping_targets'])
  end

  test 'run_with_data_with_tag_only' do
    text_index = {
      '' => {
        'en' => [
          { 'data' => '<a></a>' }
        ]
      }
    }

    UnifiedValues::DstSwappingTargetsCreator.new(text_index).run!
    assert_equal(['', '', ''], text_index['']['en'][0]['swapping_targets'])
  end

  test 'run_with_data_without_tag' do
    text_index = {
      '' => {
        'en' => [
          { 'data' => 'a' }
        ]
      }
    }

    UnifiedValues::DstSwappingTargetsCreator.new(text_index).run!
    assert_equal(['a'], text_index['']['en'][0]['swapping_targets'])
  end

  test 'run_with_data_with_wovn_ignore' do
    text_index = {
      '' => {
        'en' => [
          { 'data' => 'a<a wovn-ignore>b</a>c' }
        ]
      }
    }

    UnifiedValues::DstSwappingTargetsCreator.new(text_index).run!
    assert_equal(%w[a c], text_index['']['en'][0]['swapping_targets'])
  end

  test 'run_with_data_with_closing_tag' do
    text_index = {
      '' => {
        'en' => [
          { 'data' => 'a<br>bc' }
        ]
      }
    }

    UnifiedValues::DstSwappingTargetsCreator.new(text_index).run!
    assert_equal(%w[a bc], text_index['']['en'][0]['swapping_targets'])
  end

  test 'run_with_data_with_both_closing_tag_and_no_closing_tag' do
    text_index = {
      '' => {
        'en' => [
          { 'data' => 'a<a>b<br>c</a>d' }
        ]
      }
    }

    UnifiedValues::DstSwappingTargetsCreator.new(text_index).run!
    assert_equal(%w[a b c d], text_index['']['en'][0]['swapping_targets'])
  end
end
