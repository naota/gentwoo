# -*- coding: utf-8 -*-
# Load the rails application
require File.expand_path('../application', __FILE__)

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

# Initialize the rails application
Gentwoo::Application.initialize!

Time::DATE_FORMATS[:jp] = "%Y年%m月%d日 %H時%M分"
Time.zone = 'Tokyo'
