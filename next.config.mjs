import nextra from 'nextra'

import rehypeLuauTooltips from './plugins/luau-tooltips'

const withNextra = nextra({
  latex: true,
  staticImage: true,
  search: {
    codeblocks: false
  },
  mdxOptions: {
    rehypePlugins: [rehypeLuauTooltips],
  },
})

export default withNextra({
  images: {
    unoptimized: true,
  },
  reactStrictMode: true,
  output: 'export',
  basePath: '',
})
