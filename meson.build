project('pdftag', ['vala', 'c'],
    default_options: ['buildtype=release', 'default_library=shared'],
    version: '0.1.0')

if get_option('buildtype') == 'release'
    if meson.get_compiler('c').has_argument('-march=native')
        add_global_arguments('-march=native', language: 'c')
    endif
endif

if build_machine.system() == 'windows'
    add_global_arguments('-mwindows', language: 'c')
endif


glib = dependency('glib-2.0')
gobject = dependency('gobject-2.0')
gtk = dependency('gtk+-3.0')
poppler = dependency('poppler-glib', version: '>=0.46')

deps = [glib, gobject, gtk, poppler]

inc = include_directories('src')

srcs = ['src/main.vala']

pdftag = executable('pdftag',
    sources: srcs,
    dependencies: deps,
    install: true)

install_data('LICENSE',
    install_dir: '/usr/share/licenses/pdftag')

subdir('data')
