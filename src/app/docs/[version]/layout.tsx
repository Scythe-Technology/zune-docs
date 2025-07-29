import type { Metadata } from 'next';
import { Head, Banner, Image } from 'nextra/components';
import { Layout, Footer, Navbar, NotFoundPage } from "nextra-theme-docs";
import { getPageMap } from 'nextra/page-map';
import '../../styles/global.css';
import { generateStaticParamsFor } from 'nextra/pages';

export const metadata: Metadata = {
    title: {
        absolute: '',
        template: 'ZUNE - %s'
    }
}

export default async function ({ children, ...props }) {
    const { version } = await props.params
    const pageMap = await getPageMap("/docs/" + version);
    if (pageMap === undefined) {
        return <NotFoundPage content={null} >
            <h1 className='next-error-h1 inline-block font-medium align-top'>404</h1>
            <h1>The page is not found</h1>
        </NotFoundPage>
    }
    console.log();
    return (
        <Layout
            navbar={<></>}
            footer={<></>}
            editLink="Edit this page on GitHub"
            docsRepositoryBase="https://github.com/Scythe-Technology/zune-docs/blob/master"
            pageMap={pageMap}
            feedback={{ content: null }}
        >
            {children}
        </Layout>
    )
}