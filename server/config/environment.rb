# -*- coding: utf-8 -*-
# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Gentwoo::Application.initialize!

Time::DATE_FORMATS[:jp] = "%Y年%m月%d日 %H時%M分"
