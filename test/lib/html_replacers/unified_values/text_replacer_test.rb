require 'test_helper'

module Wovnrb
  module UnifiedValues
    module UnifiedValues
      class TextReplacerTest < WovnMiniTest
        def test_replace
          innerHtml = <<-HTML
          <div>
            a <span>b</span> c
          </div>
          <div>
            a<span>b</span>
          </div>
          <div>
            <span> b </span>c
          </div>
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

          store = Store.instance
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
          replacer = TextReplacer.new(store, text_index)

          dom = Wovnrb.get_dom(innerHtml)
          replacer.replace(dom, Lang.new('ja'))

          # node = dom.xpath('//text()')[0]
          # assert_equal('こんにちは', node.content)
          # assert_equal('wovn-src:Hello', node.previous.content)
          #
          #
          # dom = Nokogiri::HTML5(innerHtml)
          # dom.encoding = 'UTF-8'

          # api_data = build_api_data(custom_page_values: { 'text_vals' => {}, 'html_text_vals' => text_index })
          # UnifiedValues::TextReplacer.new(api_data).replace(dom, Lang.new('ja'))
          assert(dom.to_html.include?(expected_body))
        end

        def test_replace_with_dst_with_spaces
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

        def test_replace_with_empty_translations
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

        def test_replace_with_comment
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

      def test_replace_with_comment_inside_content
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

        def test_replace_without_destination_of_expected_lang
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

        def test_replace_without_expected_destination
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

        def test_replace_data_without_tag
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
  end
end
