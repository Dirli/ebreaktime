core_deps = [
    dep_glib,
    dep_gobject,
    dep_gio_unix,
    dep_gtk3,
    dep_gdk,
    dep_gee,
    dep_libxss,
    m_dep
]

if get_option('notify')
    core_deps += [dep_libnotify]
endif

executable(
    meson.project_name() + 'd',
    'AbstractManager.vala',
    'AccessManager.vala',
    'BreakManager.vala',
    'BreakWidget.vala',
    'Daemon.vala',
    'DBusService.vala',
    'Timer.vala',
    'Utils.vala',
    common_files,
    vala_args: vala_args,
    dependencies: core_deps,
    install : true
)
