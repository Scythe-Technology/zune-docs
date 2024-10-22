import Image from 'next/image';
import { useRouter } from 'next/router';
import { ThemeSwitch, useTheme } from 'nextra-theme-docs';

/**
 * @type {import('nextra-theme-docs').DocsThemeConfig}
 */
export default {
  logo: () => {
    const { theme } = useTheme()
    return <Image src={theme === "light" ? "https://raw.githubusercontent.com/Scythe-Technology/zune-docs/master/public/logo-light.svg" : "https://raw.githubusercontent.com/Scythe-Technology/zune-docs/master/public/logo-dark.svg"} className="text-center block m-auto" width={128} height={48} />
  },
  docsRepositoryBase: "https://github.com/Scythe-Technology/zune-docs/blob/master",
  project: {
    link: 'https://github.com/Scythe-Technology/Zune'
  },
  sidebar: {
    autoCollapse: false,
  },
  darkMode: true,
  navbar: {
    extraContent: (
      <ThemeSwitch lite={true} className='theme-toggle-button' />
    )
  },
  chat: {
    link: 'https://discord.gg/zEc7muuYbX',
  },
  themeSwitch: {
    component: null,
  },
  primaryHue: 210,
  primarySaturation: 50,
  footer: {
    component: <footer className="bg-neutral-200 nx-pb-[env(safe-area-inset-bottom)] dark:bg-black print:nx-bg-transparent">
      <div className="nx-mx-auto nx-flex nx-max-w-[90rem] nx-gap-2 nx-py-2 nx-px-4 nx-flex"/>
      <div className="nx-mx-auto nx-flex nx-max-w-[90rem] nx-justify-center nx-py-12 nx-text-gray-600 dark:nx-text-gray-400 md:nx-justify-start nx-pl-[max(env(safe-area-inset-left),1.5rem)] nx-pr-[max(env(safe-area-inset-right),1.5rem)]">Scythe Technology © {new Date().getFullYear()}. Licensed under the MIT License.</div>
    </footer>,
  },
  head: (
    <>
      <link rel="icon" href="https://raw.githubusercontent.com/Scythe-Technology/zune-docs/master/public/logo.svg" />
    </>
  ),
  useNextSeoProps() {
    const { asPath, pathname } = useRouter()
    if (asPath !== '/') {
      return {
        titleTemplate: `Zune - ${pathname.split('/').pop()}`
      }
    }
  }
}