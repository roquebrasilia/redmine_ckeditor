require 'rake'

module RedmineCkeditor
  class RichAssetsGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)
    desc "Generate rich asset files for Redmine"
    def create_assets
      rake "redmine_ckeditor:assets:precompile"

      gsub_file RedmineCkeditor.root.join("assets/ckeditor-contrib/plugins/richfile/plugin.js"),
        "/assets/rich/", "../images/"

      gsub_file RedmineCkeditor.root.join("assets/javascripts/application.js"),
        "opt=opt.split(',');", "opt=opt ? opt.split(',') : [];"

      gsub_file RedmineCkeditor.root.join("assets/javascripts/application.js"),
        /var CKEDITOR_BASEPATH.+$/, ""

      gsub_file RedmineCkeditor.root.join("assets/javascripts/application.js"),
        /CKEDITOR.plugins.addExternal.+$/, ""

      gsub_file RedmineCkeditor.root.join("assets/stylesheets/application.css"),
        'image-url("rich/', 'url("../images/'
    end
  end
end
