module Polyglot
  # Singleton containing Polyglot's configuration
  module Config
    class << self
      attr_accessor :file_langs, :default_lang, :languages, :keep_files,
                    :active_lang, :lang_vars, :parallel_localization,
                    :exclude_from_localization

      def fetch(site)
        @default_lang = site.config.fetch('default_lang', 'en')
        @languages = site.config.fetch('languages', ['en']).uniq
        @keep_files = (@languages - [@default_lang])
        @active_lang = @default_lang
        @lang_vars = site.config.fetch('lang_vars', [])

        @parallel_localization = site.config.fetch('parallel_localization',
                                                   true)
        @exclude_from_localization =
          site.config.fetch('exclude_from_localization', []).map do |exclude|
            exclude.prepend('/') unless exclude.start_with?('/')
            exclude
          end
      end
    end
  end
end

Jekyll::Hooks.register :site, :after_init do |site|
  Polyglot::Config.fetch(site)
end
