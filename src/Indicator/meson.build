shared_library(
    'ebreaktime',
    'Indicator.vala',
    'Popover.vala',
    client_files,
    dependencies: [
        dep_gtk3,
        dep_glib,
        dep_gio_unix,
        dep_gobject,
        wingpanel_dep,
    ],
    install: true,
    install_dir: wingpanel_dep.get_pkgconfig_variable('indicatorsdir'),
)
