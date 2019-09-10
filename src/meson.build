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
    ex_client_files,
    asresources,
    vala_args: vala_args,
    dependencies: [
        dep_gtk3,
        dep_glib,
        dep_gobject,
        dep_granite,
        dep_gee,
        dep_polkit,
        meson.get_compiler('vala').find_library('posix')
    ],
    install : true
)
