# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-uri_decoder"
  spec.version       = "0.1.1"
  spec.authors       = ["Yasuharu Ozaki"]
  spec.email         = ["yasuharu.ozaki@gmail.com"]
  spec.description   = %q{Fluent plugin to decode uri encoded value. See more https://github.com/YasuOza/fluent-plugin-uri_decoder}
  spec.summary       = %q{Fluent plugin to decode uri encoded value.}
  spec.homepage      = "https://github.com/YasuOza/fluent-plugin-uri_decoder"
  spec.license       = "Apache 2.0"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "fluentd"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
end
