
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ckb/version"

Gem::Specification.new do |spec|
  spec.name          = "ckb-sdk-ruby"
  spec.version       = CKB::VERSION
  spec.authors       = ["Nervos Core Dev"]
  spec.email         = ["dev@nervos.org"]

  spec.summary       = %q{CKB Ruby SDK.}
  spec.description   = %q{CKB Ruby SDK.}
  spec.homepage      = "https://github.com/nervosnetwork/ckb-sdk-ruby"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/nervosnetwork/ckb-sdk-ruby"
    spec.metadata["changelog_uri"] = "https://github.com/nervosnetwork/ckb-sdk-ruby/blob/master/CHANGELOG.md"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 0.66.0"
  spec.add_development_dependency "pry", "~> 0.12.2"

  spec.add_dependency "rbnacl", "~> 6.0", ">= 6.0.1"
  spec.add_dependency "bitcoin-secp256k1", "~> 0.5.0"
  spec.add_dependency "net-http-persistent", "~> 3.0.0"
end
