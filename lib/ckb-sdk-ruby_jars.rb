# rubocop:disable Naming/FileName
# rubocop:enable Naming/FileName
# frozen_string_literal: true

begin
  require "jar_dependencies"
rescue LoadError
  require "org/bouncycastle/bcprov-jdk15on/1.61/bcprov-jdk15on-1.61.jar"
end

require_jar "org.bouncycastle", "bcprov-jdk15on", "1.61" if defined? Jars
