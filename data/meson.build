icon_sizes = ['16', '24', '32', '48', '64', '128']

conf_data = configuration_data()
conf_data.set('EXEC_PATH', join_paths (get_option('prefix'), get_option('bindir'), meson.project_name() + 'd'))

foreach i : icon_sizes
    install_data(
        join_paths('icons', i, meson.project_name() + '.png'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i, 'apps')
    )
endforeach

install_data(meson.project_name() + '.gschema.xml',
    install_mode: 'rw-r--r--',
    install_dir: join_paths(get_option('datadir'), 'glib-2.0/schemas')
)

install_data(meson.project_name() + '.policy',
    install_mode: 'rw-r--r--',
    install_dir: join_paths(get_option('datadir'), 'polkit-1', 'actions')
)

configure_file(
    input: meson.project_name() + '.service.in',
    output: '@BASENAME@',
    configuration: conf_data,
    install_dir: dep_dbus.get_pkgconfig_variable('session_bus_services_dir')
)

install_data(meson.project_name() + '.desktop',
    install_dir: join_paths(get_option('datadir'), 'applications')
)

install_data(meson.project_name() + 'd.desktop',
    install_dir: join_paths(get_option('datadir'), 'applications')
)
