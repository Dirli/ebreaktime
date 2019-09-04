subdir('Common')
subdir('Core')
if get_option('indicator')
    subdir('Indicator')
endif


executable(
    meson.project_name(),
    'Application.vala',
    'MainWindow.vala',
    'Widgets/Access.vala',
    'Widgets/Break.vala',
    'Widgets/CustomGrid.vala',
    'Widgets/ServiceItem.vala',
    'Widgets/WeekSpinBox.vala',
    client_files,
    asresources,
    vala_args: vala_args,
    dependencies: [
        dep_gtk3,
        dep_glib,
        dep_gobject,
        dep_granite
    ],
    install : true
)
