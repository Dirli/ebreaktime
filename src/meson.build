subdir('Common')
subdir('Core')

executable(
    meson.project_name(),
    'Application.vala',
    'MainWindow.vala',
    'Widgets/Break.vala',
    'Widgets/CustomGrid.vala',
    'Widgets/Settings.vala',
    client_files,
    asresources,
    vala_args: vala_args,
    dependencies: [
        dep_gtk3,
        dep_glib,
        dep_gobject
    ],
    install : true
)
