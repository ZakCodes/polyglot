require_relative 'config'

module Polyglot
  # Matches all the hrefs that don't start with a ' '
  HREF_REGEX = /href="([^"# ][^"]*)"/.freeze
  ACCEPTED_SCHEMES = [nil, 'http', 'https'].freeze

  def self.localize_links(docs, site)
    docs.each do |doc|
      lang = doc.data['lang']
      next if lang == Config.default_lang || doc.output.nil?

      doc.output.gsub!(HREF_REGEX) do |match|
        uri = Addressable::URI.parse(Regexp.last_match(1))
        if should_localize?(uri, site)
        then localize_uri(uri, lang)
        else match
        end
      end
    end
  end

  def self.localize_uri(uri, lang)
    uri.path = File.join('/', lang, uri.path)
    "href=\"#{uri}\""
  end

  def self.should_localize?(uri, site)
    (uri.hostname.nil? || uri.hostname == site.config) &&
      ACCEPTED_SCHEMES.include?(uri.scheme) &&
      Config.languages.none? {|lang| uri.path.start_with?("/#{lang}") } &&
      Config.exclude_from_localization.none? do |pattern|
        File.fnmatch(pattern, uri.path)
      end
  end

  Jekyll::Hooks.register :site, :post_render do |site|
    site.collections.each do |_, collection|
      localize_links(collection.docs, site)
    end
    localize_links(site.pages, site)
  end
end
