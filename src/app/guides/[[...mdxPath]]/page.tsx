import { generateStaticParamsFor, importPage } from 'nextra/pages'
import { useMDXComponents } from '../../../../mdx-components'

export const generateStaticParams = generateStaticParamsFor('mdxPath')

export async function generateMetadata(props) {
    const params = await props.params;
    const { metadata } = await importPage(["guides", ...(params.mdxPath ? params.mdxPath : [])]);
    return metadata;
}

const Wrapper = useMDXComponents([]).wrapper

export default async function Page(props) {
    const params = await props.params;
    const { default: MDXContent, toc, metadata } = await importPage(["guides", ...(params.mdxPath ? params.mdxPath : [])]);
    return (
        <Wrapper toc={toc} metadata={metadata}>
            <MDXContent {...props} params={params} />
        </Wrapper>
    )
}