import type { Metadata } from "next";
import { Head, Banner, Image } from "nextra/components";
import { Layout, Footer, Navbar } from "nextra-theme-docs";
import { getPageMap } from "nextra/page-map";
import "./styles/global.css";
import { generateStaticParamsFor } from "nextra/pages";

export const metadata: Metadata = {
    title: {
        absolute: "",
        template: "zune - %s"
    }
}

import LOGO_DARK from "../../public/logo-dark.svg";
import LOGO_LIGHT from "../../public/logo-light.svg";
import LOGO from "../../public/logo.svg";

import TooltipHover from "./components/TooltipHover";

export default async function ({ children, ...props }) {
    const navbar = (
        <Navbar
            logo={<>
                <Image src={LOGO_LIGHT} className="text-center block dark:hidden m-auto" style={{ height: '72px', objectFit: "cover" }} width={128} alt={"ZUNE"} />
                <Image src={LOGO_DARK} className="text-center dark:block hidden m-auto" style={{ height: '72px', objectFit: "cover" }} width={128} alt={"ZUNE"} />
            </>}
            projectLink="https://github.com/Scythe-Technology/zune"
            chatLink="https://discord.gg/zEc7muuYbX"
        />
    )
    return (
        <html
            lang="en"
            dir="ltr"
            suppressHydrationWarning
        >
            <Head
                color={{
                    hue: 0,
                    saturation: 0,
                    lightness: {
                        light: 25,
                        dark: 100
                    }
                }}>
                <meta content="ZUNE" property="og:title" />
                <meta content="A luau runtime" property="og:description" />
                <meta content="#151515" name="theme-color" />
                <meta content="https://raw.githubusercontent.com/Scythe-Technology/zune-docs/master/public/logo-tag.png" property="og:image" />
                <meta name="twitter:card" content="summary_large_image" />
                <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                <link rel="icon" href="https://raw.githubusercontent.com/Scythe-Technology/zune-docs/master/public/logo.svg" />
            </Head>
            <body>
                <Layout
                    navbar={navbar}
                    footer={<Footer>Scythe Technology © {new Date().getFullYear()}. Licensed under the MIT License.</Footer>}
                    docsRepositoryBase="https://github.com/Scythe-Technology/zune-docs/blob/master"
                    feedback={{ content: null }}
                    pageMap={await getPageMap()}
                >
                    {children}
                </Layout>
                <TooltipHover />
            </body>
        </html>
    )
}