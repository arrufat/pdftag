project('pdftag', ['vala', 'c'],
    default_options: ['buildtype=release'],
    version: '2.0.0',
    license: 'GPL3+')

add_project_arguments('-DVERSION="@0@"'.format(meson.project_version()), language: 'c')

deps = [
    dependency('glib-2.0'),
    dependency('gobject-2.0'),
    dependency('gtk4', version: '>=4.20'),
    dependency('libadwaita-1', version: '>=1.6'),
    dependency('poppler-glib', version: '>=20.09'),
]

pdftag = executable('pdftag',
    sources: ['src/main.vala'],
    dependencies: deps,
    win_subsystem: 'windows',
    install: true)

install_data('LICENSE',
    install_dir: 'share/licenses/pdftag')

subdir('data')
