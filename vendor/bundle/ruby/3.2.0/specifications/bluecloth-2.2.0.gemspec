# -*- encoding: utf-8 -*-
# stub: bluecloth 2.2.0 ruby lib
# stub: ext/extconf.rb

Gem::Specification.new do |s|
  s.name = "bluecloth".freeze
  s.version = "2.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Michael Granger".freeze]
  s.cert_chain = ["-----BEGIN CERTIFICATE-----\nMIIDLDCCAhSgAwIBAgIBADANBgkqhkiG9w0BAQUFADA8MQwwCgYDVQQDDANnZWQx\nFzAVBgoJkiaJk/IsZAEZFgdfYWVyaWVfMRMwEQYKCZImiZPyLGQBGRYDb3JnMB4X\nDTEwMDkxNjE0NDg1MVoXDTExMDkxNjE0NDg1MVowPDEMMAoGA1UEAwwDZ2VkMRcw\nFQYKCZImiZPyLGQBGRYHX2FlcmllXzETMBEGCgmSJomT8ixkARkWA29yZzCCASIw\nDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALy//BFxC1f/cPSnwtJBWoFiFrir\nh7RicI+joq/ocVXQqI4TDWPyF/8tqkvt+rD99X9qs2YeR8CU/YiIpLWrQOYST70J\nvDn7Uvhb2muFVqq6+vobeTkILBEO6pionWDG8jSbo3qKm1RjKJDwg9p4wNKhPuu8\nKGue/BFb67KflqyApPmPeb3Vdd9clspzqeFqp7cUBMEpFS6LWxy4Gk+qvFFJBJLB\nBUHE/LZVJMVzfpC5Uq+QmY7B+FH/QqNndn3tOHgsPadLTNimuB1sCuL1a4z3Pepd\nTeLBEFmEao5Dk3K/Q8o8vlbIB/jBDTUx6Djbgxw77909x6gI9doU4LD5XMcCAwEA\nAaM5MDcwCQYDVR0TBAIwADALBgNVHQ8EBAMCBLAwHQYDVR0OBBYEFJeoGkOr9l4B\n+saMkW/ZXT4UeSvVMA0GCSqGSIb3DQEBBQUAA4IBAQBG2KObvYI2eHyyBUJSJ3jN\nvEnU3d60znAXbrSd2qb3r1lY1EPDD3bcy0MggCfGdg3Xu54z21oqyIdk8uGtWBPL\nHIa9EgfFGSUEgvcIvaYqiN4jTUtidfEFw+Ltjs8AP9gWgSIYS6Gr38V0WGFFNzIH\naOD2wmu9oo/RffW4hS/8GuvfMzcw7CQ355wFR4KB/nyze+EsZ1Y5DerCAagMVuDQ\nU0BLmWDFzPGGWlPeQCrYHCr+AcJz+NRnaHCKLZdSKj/RHuTOt+gblRex8FAh8NeA\ncmlhXe46pZNJgWKbxZah85jIjx95hR8vOI+NAM5iH9kOqK13DrxacTKPhqj5PjwF\n-----END CERTIFICATE-----\n".freeze]
  s.date = "2011-11-01"
  s.description = "BlueCloth is a Ruby implementation of John Gruber's\nMarkdown[http://daringfireball.net/projects/markdown/], a text-to-HTML\nconversion tool for web writers. To quote from the project page: Markdown\nallows you to write using an easy-to-read, easy-to-write plain text format,\nthen convert it to structurally valid XHTML (or HTML).\n\nIt borrows a naming convention and several helpings of interface from\n{Redcloth}[http://redcloth.org/], Why the Lucky Stiff's processor for a\nsimilar text-to-HTML conversion syntax called\nTextile[http://www.textism.com/tools/textile/].\n\nBlueCloth 2 is a complete rewrite using David Parsons'\nDiscount[http://www.pell.portland.or.us/~orc/Code/discount/] library, a C\nimplementation of Markdown. I rewrote it using the extension for speed and\naccuracy; the original BlueCloth was a straight port from the Perl version\nthat I wrote in a few days for my own use just to avoid having to shell out to\nMarkdown.pl, and it was quite buggy and slow. I apologize to all the good\npeople that sent me patches for it that were never released.\n\nNote that the new gem is called 'bluecloth' and the old one 'BlueCloth'. If\nyou have both installed, you can ensure you're loading the new one with the\n'gem' directive:\n\n\t# Load the 2.0 version\n\tgem 'bluecloth', '>= 2.0.0'\n\t\n\t# Load the 1.0 version\n\tgem 'BlueCloth'\n\trequire 'bluecloth'".freeze
  s.email = ["ged@FaerieMUD.org".freeze]
  s.executables = ["bluecloth".freeze]
  s.extensions = ["ext/extconf.rb".freeze]
  s.extra_rdoc_files = ["Manifest.txt".freeze, "README.rdoc".freeze, "History.rdoc".freeze]
  s.files = ["History.rdoc".freeze, "Manifest.txt".freeze, "README.rdoc".freeze, "bin/bluecloth".freeze, "ext/extconf.rb".freeze]
  s.homepage = "http://deveiate.org/projects/BlueCloth".freeze
  s.licenses = ["BSD".freeze]
  s.rdoc_options = ["--main".freeze, "README.rdoc".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "BlueCloth is a Ruby implementation of John Gruber's Markdown[http://daringfireball.net/projects/markdown/], a text-to-HTML conversion tool for web writers".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 3

  s.add_development_dependency(%q<hoe-mercurial>.freeze, ["~> 1.3.1"])
  s.add_development_dependency(%q<hoe-highline>.freeze, ["~> 0.0.1"])
  s.add_development_dependency(%q<tidy-ext>.freeze, ["~> 0.1"])
  s.add_development_dependency(%q<rake-compiler>.freeze, ["~> 0.7"])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 2.6"])
  s.add_development_dependency(%q<hoe>.freeze, ["~> 2.12"])
end
