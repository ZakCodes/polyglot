require_relative 'config'

module Jekyll
  class Page
    attr_writer :data, :url
  end
  class Document
    attr_writer :data, :url
  end
end

module Polyglot
  # Infers the language of a page based on it's url and removes the language
  # from it's url. Ex.: something.en.html => /en/something.html,
  # something.fr.html => /fr/something.html.
  # When no translation of a page is found, the `default_lang`'s page is copied
  # and it's language is changed to the language of the missing translation.
  class TranslationsGenerator < Jekyll::Generator
    safe true

    def generate(site)
      site.collections.each do |_, collection|
        collection.docs = handle_pages(collection.docs)
      end
      site.pages = handle_pages(site.pages)
    end

    def handle_pages(pages)
      urls = {}
      pages.each do |page|
        lang = page.data['lang'] ||
               Config.languages.find do |language|
                 page.url.end_with?(".#{language}")
               end

        lang = Config.default_lang unless lang.is_a?(String)

        page.url.chomp!(".#{lang}")
        page.data['lang'] = lang

        if urls[page.url]
        then urls[page.url][lang] = page
        else urls[page.url] = { lang => page }
        end
      end

      generated = []
      urls.each do |url, translations|
        default_translation = translations[Config.default_lang]
        Config.languages.each do |lang|
          translation = translations[lang]
          unless translation
            next unless default_translation

            translation = default_translation.clone
            translation.data = default_translation.data.clone
          end
          translation.data['lang'] = lang
          translation.url = '/' + lang + url if lang != Config.default_lang
          generated.push(translation)
        end
      end
      generated
    end
  end
end
