# frozen_string_literal: true

def extract_number(string)
  string.strip.gsub(/\D/, '').to_i
end

def get_gender(string)
  string.split(' ')[0].gsub(/\d/, '')
end

def colorize(value, color)
  case color
  when :red then puts "\e[31m#{value}\e[0m"
  when :green then puts "\e[32m#{value}\e[0m"
  when :yellow then puts "\e[33m#{value}\e[0m"
  when :blue then puts "\e[34m#{value}\e[0m"
  when :magenta then puts "\e[35m#{value}\e[0m"
  when :cyan then puts "\e[36m#{value}\e[0m"
  when :white then puts "\e[37m#{value}\e[0m"
  when :bright_black then puts "\e[1m\e[30m#{value}\e[0m"
  when :bright_red then puts "\e[1m\e[31m#{value}\e[0m"
  when :bright_green then puts "\e[1m\e[32m#{value}\e[0m"
  when :bright_yellow then puts "\e[1m\e[33m#{value}\e[0m"
  when :bright_blue then puts "\e[1m\e[34m#{value}\e[0m"
  when :bright_magenta then puts "\e[1m\e[35m#{value}\e[0m"
  when :bright_cyan then puts "\e[1m\e[36m#{value}\e[0m"
  when :bright_white then puts "\e[1m\e[37m#{value}\e[0m"
  else puts "\e[30m#{value}\e[0m"
  end
end
