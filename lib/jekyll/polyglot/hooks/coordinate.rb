# hook to coordinate blog posts and pages into distinct urls,
# and remove duplicate multilanguage posts and pages
Jekyll::Hooks.register :site, :post_read do |site|
  hook_coordinate(site)
end

def hook_coordinate(site)
  # Copy the language specific data, by recursively merging it with the default data.
  # Favour active_lang first, then default_lang, then any non-language-specific data.
  # See: https://www.ruby-forum.com/topic/142809
  merger = proc { |_key, v1, v2| Hash == v1 && Hash == v2 ? v1.merge(v2, &merger) : v2 }
  if site.data.include?(site.default_lang)
    site.data = site.data.merge(site.data[site.default_lang], &merger)
  end
  if site.data.include?(site.active_lang)
    site.data = site.data.merge(site.data[site.active_lang], &merger)
  end

  site.collections.each do |_, collection|
    collection.docs = coordinate_documents(site, collection.docs)
  end
  site.pages = coordinate_documents(site, site.pages)
end

# assigns natural permalinks to documents and prioritizes documents with
# active_lang languages over others
def coordinate_documents(site, docs)
  regex = document_url_regex(site)
  # active_lang = site.active_lang
  approved = {}
  puts '------------------'
  default_lang = site.default_lang
  docs.each do |doc|
    lang = doc.data['lang'] || site.default_lang
    ref = doc.data['ref'] || doc.url.gsub(regex, '/')
    path = doc.path
    puts lang + '  .  ' + path + '   .   ' + ref
    doc.data['path'] = lang == default_lang ? path : "/#{lang}#{path}"
    # next if site.file_langs[ref] == active_lang
    # next if site.file_langs[ref] == default_lang && lang != active_lang
    approved[ref] = doc
    # site.file_langs[ref] = lang
  end
  approved
end

# a regex that matches urls or permalinks with i18n prefixes or suffixes
# matches /en/foo , .en/foo , foo.en/ and other simmilar default urls
# made by jekyll when parsing documents without explicitly set permalinks
def document_url_regex(site)
  regex = ''
  site.languages.each do |lang|
    regex += "([\/\.]#{lang}[\/\.])|"
  end
  regex.chomp! '|'
  %r{#{regex}}
end