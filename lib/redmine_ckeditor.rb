require 'redmine_ckeditor/application_helper_patch'
require 'redmine_ckeditor/rich_files_helper_patch'
require 'redmine_ckeditor/journals_controller_patch'
require 'redmine_ckeditor/messages_controller_patch'
require 'redmine_ckeditor/hooks/journal_listener'

module RedmineCkeditor
  extend ActionView::Helpers

  def self.root
    @root ||= Pathname(File.expand_path(File.dirname(File.dirname(__FILE__))))
  end

  def self.assets_root
    "#{Redmine::Utils.relative_url_root}/plugin_assets/redmine_ckeditor"
  end

  ALLOWED_TAGS = %w[
    a abbr acronym address blockquote b big br caption cite code dd del dfn
    div dt em h1 h2 h3 h4 h5 h6 hr i img ins kbd li ol p pre samp small span
    strike strong sub sup table tbody td tfoot th thead tr tt u ul var iframe
  ]

  ALLOWED_ATTRIBUTES = %w[
    href src width height alt cite datetime title class name xml:lang abbr dir
    style align valign border cellpadding cellspacing colspan rowspan nowrap
  ]

  DEFAULT_TOOLBAR = %w[
    Source ShowBlocks -- Undo Redo - Find Replace --
    Bold Italic Underline Strike - Subscript Superscript -
    NumberedList BulletedList - Outdent Indent Blockquote -
    JustifyLeft JustifyCenter JustifyRight JustifyBlock -
    Link Unlink - richImage Table HorizontalRule
    /
    Styles Format Font FontSize - TextColor BGColor
  ].join(",")

  def self.config
    ActionController::Base.config
  end

  def self.plugins
    @plugins ||= Dir.glob(root.join("assets/ckeditor-contrib/plugins/*")).map {
      |path| File.basename(path)
    }
  end

  def self.skins
    @skins ||= Dir.glob(root.join("assets/ckeditor-contrib/skins/*")).map {
      |path| File.basename(path)
    }
  end

  def self.skin_options
    options_for_select(["moono"] + skins, :selected => RedmineCkeditorSetting.skin)
  end

  def self.options(scope_object = nil)
    scope_type = scope_object && scope_object.class.model_name
    scope_id = scope_object && scope_object.id

    skin = RedmineCkeditorSetting.skin
    skin += ",#{assets_root}/ckeditor-contrib/skins/#{skin}/" if skin != "moono"

    o = Rich.options({
      :richBrowserUrl => "#{Redmine::Utils.relative_url_root}/rich/files/",
      :contentsCss => stylesheet_path("application"),
      :bodyClass => "wiki",
      :extraPlugins => plugins.join(","),
      :removePlugins => 'div,flash,forms,iframe,image',
      :skin => skin,
      :uiColor => RedmineCkeditorSetting.ui_color,
      :toolbar => RedmineCkeditorSetting.toolbar,
      :scoped => scope_object ? true : false
    }, scope_type, scope_id)
    o.delete(:removeDialogTabs)
    o.delete(:format_tags)
    o.delete(:stylesSet)
    o
  end

  def self.enabled?
    Setting.text_formatting == "CKEditor"
  end

  def self.apply_patch
    JournalsController.send(:include, JournalsControllerPatch)
    MessagesController.send(:include, MessagesControllerPatch)
    Rich::FilesHelper.send(:include, RichFilesHelperPatch)
  end
end
