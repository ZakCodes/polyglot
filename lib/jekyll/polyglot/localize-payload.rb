require_relative 'config'

module Polyglot
  def self.merge_recursive(base, additional)
    # Copy the language specific data, by recursively merging it with the
    # default data. Favour active_lang first, then default_lang, then any
    # non-language-specific data. See: https://www.ruby-forum.com/topic/142809
    merger = proc { |_key, v1, v2|
      next v2 unless v1.is_a?(Hash) && v2.is_a?(Hash)

      v1.merge(v2, &merger)
    }
    base.merge!(additional, &merger)
  end

  localize_payload = lambda do |page, payload|
    page_lang = page.data['lang'] || payload['site']['default_lang']
    payload['site']['active_lang'] = page_lang

    site_data = payload['site']['data']
    lang_data = site_data[page_lang]
    merge_recursive(site_data, lang_data)

    # What is the point of those lines???
    Config.lang_vars.each do |v|
      payload['site'][v] = page_lang
    end
  end

  Jekyll::Hooks.register :pages, :pre_render, &localize_payload
  Jekyll::Hooks.register :documents, :pre_render, &localize_payload

  Jekyll::Hooks.register :site, :pre_render do |_site, payload|
    payload['site']['default_lang'] = Config.default_lang
    payload['site']['languages'] = Config.languages
  end
end
