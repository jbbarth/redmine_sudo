require File.expand_path('../../../vhod_common/spec/rails_helper', __FILE__)
include VhodCommonSpec

FactoryGirl.definition_file_paths |= [
    File.expand_path('../factories', __FILE__),
    VhodCommonSpec.plugin_factories_path(:vhod_common)
]
FactoryGirl.reload