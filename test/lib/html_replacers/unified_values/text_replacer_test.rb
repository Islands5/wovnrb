require 'test_helper'

module Wovnrb
  class UnifiedValuesTextReplacerTest < WovnMiniTest
    test 'replace' do
      html = <<-HTML
      <html>
        <body>
          <div>
            a <span>b</span> c
          </div>
          <div>
            a<span>b</span>
          </div>
          <div>
            <span> b </span>c
          </div>
        </body>
      </html>
      HTML

      expected_body = <<~HTML
                <div>
      <!--wovn-src:
                  a -->あ<span><!--wovn-src:b-->い</span><!--wovn-src: c
                -->う</div>
                <div>
      <!--wovn-src:
                  a-->\u200b<span><!--wovn-src:b-->い</span><!--wovn-src:-->う
                </div>
                <div>
                  <!--wovn-src:-->あ<span><!--wovn-src: b -->い</span><!--wovn-src:c
                -->\u200b</div>
      HTML

      text_index = {
        'a<span>b</span>c' =>
        { 'ja' =>
          [{ 'data' => 'あ<span>い</span>う' }] },
        'a<span>b</span>' =>
          { 'ja' =>
            [{ 'data' => '<span>い</span>う' }] },
          '<span>b</span>c' =>
            { 'ja' =>
              [{ 'data' => 'あ<span>い</span>' }] }
      }

      dom = Nokogiri::HTML5(html)
      dom.encoding = 'UTF-8'

      api_data = build_api_data(custom_page_values: { 'text_vals' => {}, 'html_text_vals' => text_index })
      UnifiedValues::TextReplacer.new(api_data).replace(dom, Lang.new('ja'))
      assert(dom.to_html.include?(expected_body))
    end

    test 'replace_with_dst_with_spaces' do
      html = <<-HTML
      <html>
        <body>
          <div>
            a <span>b</span> c
          </div>
          <div>
            a<span>b</span>
          </div>
          <div>
            <span> b </span>c
          </div>
        </body>
      </html>
      HTML

      expected_body = <<~HTML
                <div>
      <!--wovn-src:
                  a -->あ <span><!--wovn-src:b--> い </span><!--wovn-src: c
                --> う</div>
                <div>
      <!--wovn-src:
                  a-->\u200b<span><!--wovn-src:b--> い </span><!--wovn-src:--> う
                </div>
                <div>
                  <!--wovn-src:-->あ <span><!--wovn-src: b --> い </span><!--wovn-src:c
                -->\u200b</div>
      HTML

      text_index = {
        'a<span>b</span>c' =>
        { 'ja' =>
          [{ 'data' => 'あ <span> い </span> う' }] },
        'a<span>b</span>' =>
          { 'ja' =>
            [{ 'data' => '<span> い </span> う' }] },
          '<span>b</span>c' =>
            { 'ja' =>
              [{ 'data' => 'あ <span> い </span>' }] }
      }

      dom = Nokogiri::HTML5(html)
      dom.encoding = 'UTF-8'
      api_data = build_api_data(custom_page_values: { 'text_vals' => {}, 'html_text_vals' => text_index })
      UnifiedValues::TextReplacer.new(api_data).replace(dom, Lang.new('ja'))
      assert(dom.to_html.include?(expected_body))
    end

    test 'replace_with_empty_translations' do
      html = <<-HTML
      <html>
        <body>
          <p> a </p>
          <div>
            a <span> b </span> c
          </div>
        </body>
      </html>
      HTML

      expected_body = <<~HTML
                <p><!--wovn-src: a -->\u200b</p>
                <div>
      <!--wovn-src:
                  a -->\u200b<span><!--wovn-src: b -->い</span><!--wovn-src: c
                -->\u200b</div>
      HTML

      text_index = {
        'a<span>b</span>c' =>
        { 'ja' =>
          [{ 'data' => '<span>い</span>' }] },
        'a' =>
          { 'ja' =>
            [{ 'data' => "\u200b" }] }
      }

      dom = Nokogiri::HTML5(html)
      dom.encoding = 'UTF-8'

      api_data = build_api_data(custom_page_values: { 'text_vals' => {}, 'html_text_vals' => text_index })
      UnifiedValues::TextReplacer.new(api_data).replace(dom, Lang.new('ja'))
      assert(dom.to_html.include?(expected_body))
    end

    test 'replace with comment' do
      html = <<-HTML
      <html>
        <body>
          <div>
            <!-- comment -->
            a <span>b</span> c
          </div>
        </body>
      </html>
      HTML

      expected_body = <<-HTML
          <div>
            <!-- comment --><!--wovn-src:
            a -->あ<span><!--wovn-src:b-->い</span><!--wovn-src: c
          -->う</div>
      HTML

      text_index = {
        'a<span>b</span>c' =>
        { 'ja' =>
          [{ 'data' => 'あ<span>い</span>う' }] }
      }

      dom = Nokogiri::HTML5(html)
      dom.encoding = 'UTF-8'

      api_data = build_api_data(custom_page_values: { 'text_vals' => {}, 'html_text_vals' => text_index })
      UnifiedValues::TextReplacer.new(api_data).replace(dom, Lang.new('ja'))
      assert(dom.to_html.include?(expected_body))
    end

    test 'replace with comment inside content' do
      html = <<-HTML
      <html>
        <body>
          <div>
            a<!-- comment --> <span><!-- comment -->b<!-- comment --></span><!-- comment --> c<!-- comment -->
          </div>
        </body>
      </html>
      HTML

      expected_body = <<~HTML
                <div>
      <!--wovn-src:
                  a-->あ<!-- comment --> <span><!-- comment --><!--wovn-src:b-->い<!-- comment --></span><!-- comment --><!--wovn-src: c-->う<!-- comment -->
                </div>
      HTML

      text_index = {
        'a<span>b</span>c' =>
        { 'ja' =>
          [{ 'data' => 'あ<span>い</span>う' }] }
      }

      dom = Nokogiri::HTML5(html)
      dom.encoding = 'UTF-8'

      api_data = build_api_data(custom_page_values: { 'text_vals' => {}, 'html_text_vals' => text_index })
      UnifiedValues::TextReplacer.new(api_data).replace(dom, Lang.new('ja'))
      assert(dom.to_html.include?(expected_body))
    end

    test 'replace without destination of expected lang' do
      html = <<-HTML
      <html>
        <body>
          <div>
            a <span>b</span> c
          </div>
        </body>
      </html>
      HTML

      expected_body = <<-HTML
          <div>
            a <span>b</span> c
          </div>
      HTML

      text_index = {
        'a<span>b</span>c' =>
        { 'it' =>
          [{ 'data' => 'あ<span>い</span>う' }] }
      }

      dom = Nokogiri::HTML5(html)
      dom.encoding = 'UTF-8'

      api_data = build_api_data(custom_page_values: { 'text_vals' => {}, 'html_text_vals' => text_index })
      UnifiedValues::TextReplacer.new(api_data).replace(dom, Lang.new('ja'))
      assert(dom.to_html.include?(expected_body))
    end

    test 'replace without expected destination' do
      html = <<-HTML
      <html>
        <body>
          <div>
            a <span>b</span> c
          </div>
        </body>
      </html>
      HTML

      expected_body = <<-HTML
          <div>
            a <span>b</span> c
          </div>
      HTML

      text_index = {}

      dom = Nokogiri::HTML5(html)
      dom.encoding = 'UTF-8'

      api_data = build_api_data(custom_page_values: { 'text_vals' => {}, 'html_text_vals' => text_index })
      UnifiedValues::TextReplacer.new(api_data).replace(dom, Lang.new('ja'))
      assert(dom.to_html.include?(expected_body))
    end

    test 'replace_data_without_tag' do
      html = <<-HTML
      <html>
        <body>
          <div>
            apple
          </div>
        </body>
      </html>
      HTML

      expected_body = <<~HTML
      <!--wovn-src:
                  apple
                -->りんご</div>
      HTML

      text_index = {
        'apple' =>
        { 'ja' =>
          [{ 'data' => 'りんご' }] }
      }

      dom = Nokogiri::HTML5(html)
      dom.encoding = 'UTF-8'

      api_data = build_api_data(custom_page_values: { 'text_vals' => {}, 'html_text_vals' => text_index })
      UnifiedValues::TextReplacer.new(api_data).replace(dom, Lang.new('ja'))
      assert(dom.to_html.include?(expected_body))
    end
  end
end
