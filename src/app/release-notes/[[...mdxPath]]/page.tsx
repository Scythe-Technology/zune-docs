import { PageMapItem } from 'nextra';
import { importPage } from 'nextra/pages'
import { getPageMap } from 'nextra/page-map';
import { useMDXComponents } from '../../../../mdx-components'

export async function generateStaticParams() {
    const pages = await getPageMap("/release-notes/");
    var result: { mdxPath: string[] }[] = [];
    const scanPage = (page: PageMapItem) => {
        if ("route" in page) {
            const mdxPath = page.route.split('/').filter((s) => s !== '');
            mdxPath.splice(0, 1);
            result.push({ mdxPath: mdxPath });
            if ("children" in page)
                page.children.forEach(scanPage);
        }
    }
    pages.forEach(scanPage);
    return result;
}

export async function generateMetadata(props) {
    const params = await props.params;
    const { metadata } = await importPage(["release-notes", ...(params.mdxPath ? params.mdxPath : [])]);
    return metadata;
}

const Wrapper = useMDXComponents([]).wrapper

export default async function Page(props) {
    const params = await props.params;
    const { default: MDXContent, toc, metadata } = await importPage(["release-notes", ...(params.mdxPath ? params.mdxPath : [])]);
    return (
        <Wrapper toc={toc} metadata={metadata}>
            <MDXContent {...props} params={params} />
        </Wrapper>
    )
}