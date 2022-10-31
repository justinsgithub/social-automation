# frozen_string_literal: true

def extract_number(string)
  string.strip.gsub(/\D/, '').to_i
end

def get_gender(string)
  string.split(' ')[0].gsub(/\d/, '')
end

COLORS = {
  red: "\e[31m",
  green: "\e[32m",
  yellow: "\e[33m",
  blue: "\e[34m",
  magenta: "\e[35m",
  cyan: "\e[36m",
  white: "\e[37m",
  bright_black: "\e[1m\e[30m",
  bright_red: "\e[1m\e[31m",
  bright_green: "\e[1m\e[32m",
  bright_yellow: "\e[1m\e[33m",
  bright_blue: "\e[1m\e[34m",
  bright_magenta: "\e[1m\e[35m",
  bright_cyan: "\e[1m\e[36m",
  bright_white: "\e[1m\e[37m"
}.freeze

def colorize(value, color)
  puts "#{COLORS[color]}#{value}\e[0m"
end
