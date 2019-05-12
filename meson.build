project(
    'io.elementary.ebreaktime',
    'vala', 'c',
    version: '0.3.0'
)

add_global_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language:'c'
)

dep_gtk3 = dependency('gtk+-3.0')
dep_glib = dependency('glib-2.0')
dep_gio_unix = dependency('gio-unix-2.0')
dep_gobject = dependency('gobject-2.0')
dep_dbus = dependency('dbus-1')

vala_args = []
if get_option('notify')
    dep_libnotify = dependency('libnotify')
    vala_args += ['--define=NOTIFY_ENABLE']
endif

m_dep = meson.get_compiler('c').find_library('m', required : false)

subdir('data')
subdir('src')

meson.add_install_script('meson/meson_post_install.py')
