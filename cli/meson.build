cli_deps = [
    dep_gee,
    dep_gio,
    dep_glib
]

executable(
    meson.project_name() + '-cli',
    'Main.vala',
    common_files_minimal,
    dependencies: cli_deps,
    install : true
)
