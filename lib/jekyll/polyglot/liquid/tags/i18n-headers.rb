require_relative '../../config'

module Jekyll
  module Polyglot
    module Liquid
      class I18nHeadersTag < ::Liquid::Tag
        def initialize(tag_name, text, tokens)
          super
          @url = text
          @url.strip!
          @url.chomp! '/'
        end

        def render(context)
          site = context.registers[:site]
          permalink = context.registers[:page]['permalink']
          active_lang = context.registers[:page]['permalink']
          site_url = @url.empty? ? site.config['url'] : @url
          i18n = "<meta http-equiv=\"Content-Language\"
                        content=\"#{active_lang}\">\n"
          i18n += "<link rel=\"alternate\"
                   hreflang=\"#{::Polyglot::Config.default_lang}\"
                   href=\" #{site_url}#{permalink}\"/>\n"
          ::Polyglot::Config.languages.each do |lang|
            next if lang == ::Polyglot::Config.default_lang

            i18n += "<link rel=\"alternate\" hreflang=\"#{lang}\" "\
            "href=\"#{site_url}/#{lang}#{permalink}\"/>\n"
          end
          i18n
        end
      end
    end
  end
end

Liquid::Template.register_tag(
  'I18n_Headers',
  Jekyll::Polyglot::Liquid::I18nHeadersTag
)
