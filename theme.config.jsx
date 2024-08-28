import Image from 'next/image';
import { useRouter } from 'next/router';
import { ThemeSwitch, useTheme } from 'nextra-theme-docs';

import { Navbar } from './components/navbar';

/**
 * @type {import('nextra-theme-docs').DocsThemeConfig}
 */
export default {
  logo: () => {
    const { theme } = useTheme()
    return <Image src={theme === "light" ? "/zune-docs/logo-light.svg" : "/zune-docs/logo-dark.svg"} className="text-center block m-auto" width={128} height={48} />
  },
  docsRepositoryBase: "https://github.com/Scythe-Technology/zune-docs/blob/main",
  project: {
    link: 'https://github.com/Scythe-Technology/Zune'
  },
  sidebar: {
    autoCollapse: false,
  },
  darkMode: true,
  navbar: {
    component: Navbar,
    extraContent: (
      <ThemeSwitch lite={true} className='theme-toggle-button' />
    )
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
      <link rel="icon" href="/zune-docs/logo.svg" />
    </>
  ),
  useNextSeoProps() {
    const { asPath } = useRouter()
    if (asPath !== '/') {
      return {
        titleTemplate: 'Zune - %s'
      }
    }
  }
}