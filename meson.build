project(
    'io.elementary.ebreaktime',
    'vala', 'c',
    version: '1.9.0'
)

gnome = import('gnome')
i18n = import('i18n')

add_global_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language:'c'
)

add_project_arguments ([
        '--vapidir', join_paths (meson.current_source_dir (), 'vapi'),
    ],
    language: 'vala'
)

asresources = gnome.compile_resources(
    'as-resources', join_paths('data', meson.project_name() + '.gresource.xml'),
    source_dir: 'data',
    c_name: 'as'
)

dep_gtk3 = dependency('gtk+-3.0')
dep_glib = dependency('glib-2.0')
dep_gio_unix = dependency('gio-unix-2.0')
dep_gio = dependency('gio-2.0')
dep_gobject = dependency('gobject-2.0')
dep_dbus = dependency('dbus-1')
dep_gdk = dependency('gdk-x11-3.0')
dep_libxss = dependency('xscrnsaver')
dep_granite = dependency('granite')
dep_gee = dependency ('gee-0.8')
dep_polkit = dependency('polkit-gobject-1')
dep_posix = meson.get_compiler('vala').find_library('posix')

vala_args = []
if get_option('notify')
    dep_libnotify = dependency('libnotify')
    vala_args += ['--define=NOTIFY_ENABLE']
endif

if get_option('indicator')
    wingpanel_dep = dependency('wingpanel-2.0')
    vala_args += ['--define=INDICATOR_EXIST']
endif

m_dep = meson.get_compiler('c').find_library('m', required : false)

subdir('data')
subdir('src')
subdir('cli')
subdir('po')

meson.add_install_script('meson/meson_post_install.py')
