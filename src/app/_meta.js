export default {
    index: {
        type: 'page',
        display: 'hidden',
    },
    download: {
        title: 'Download',
        type: 'page',
        href: 'https://github.com/Scythe-Technology/zune/releases'
    },
    documentation: {
        title: 'Docs',
        type: 'menu',
        items: {
            // 'master': {
            //     title: 'master',
            //     href: '/docs/master'
            // },
            'v0.4.2': {
                title: 'v0.4.2',
                href: '/docs/v0.4.2'
            },
        }
    },
    guides: {
        title: 'Guides',
        type: 'page',
        href: '/guides'
    },
    release_notes: {
        title: 'Release Notes',
        type: 'page',
        href: '/release-notes'
    },
}