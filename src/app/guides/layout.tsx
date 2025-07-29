import type { Metadata } from 'next';
import { Layout, NotFoundPage } from "nextra-theme-docs";
import { getPageMap } from 'nextra/page-map';
import '../styles/global.css';

export const metadata: Metadata = {
    title: {
        absolute: '',
        template: '%s'
    }
}

export default async function ({ children }) {
    let pageMap;
    try {
        pageMap = await getPageMap("/guides");
        if (pageMap === undefined)
            throw new Error("Page map not found");
    } catch (error) {
        return <NotFoundPage content={null} >
            <h1 className='next-error-h1 inline-block font-medium align-top'>404</h1>
            <h1>The page is not found</h1>
        </NotFoundPage>
    }
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