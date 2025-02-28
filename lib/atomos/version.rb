# typed: strict
# frozen_string_literal: true

require 'sorbet-runtime'

module Atomos
  extend T::Sig

  sig { returns(String) }
  def self.version
    VERSION
  end

  VERSION = T.let(File.read(File.expand_path('../../VERSION', __dir__)), String)
end
