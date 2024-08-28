import nextra from 'nextra';

import {BUNDLED_LANGUAGES, getHighlighter} from 'shiki';

export default nextra({
  theme: 'nextra-theme-docs',
  themeConfig: './theme.config.jsx',
  latex: true,
  standalone: true,
  staticImage: true,
  flexsearch: {
    codeblock: false
  },
  mdxOptions: {
    rehypePrettyCodeOptions: {
      getHighlighter: options =>
        getHighlighter({
          ...options,
          langs: [
            ...BUNDLED_LANGUAGES,
            {
              id: 'luau',
              scopeName: 'source.luau',
              aliases: [], // Along with id, aliases will be included in the allowed names you can use when writing markdown.
              path: '../../public/syntax/luau.tmLanguage.json'
            }
          ]
        })
    }
  }
})({
  images: {
    unoptimized: true,
  },
  reactStrictMode: true,
  output: 'export',
  basePath: '/pages',
})