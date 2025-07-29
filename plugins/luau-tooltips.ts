import { createHighlighter } from "shiki";
import { SKIP, visitParents } from "unist-util-visit-parents";

import { ElementContent, Element, Root } from "hast";

function getCode(root: Root): Element | undefined {
    const pre_hast = root.children[0];
    if (!pre_hast || pre_hast.type !== "element")
        return;
    const code_hast = pre_hast.children[0];
    if (!code_hast || code_hast.type !== "element" || code_hast.tagName !== "code")
        return;
    return code_hast;
}

function parseHoverComments(code: string) {
    const lines = code.split('\n');
    const hover_data: { start: number, end: number, content?: Element, line: number }[] = [];
    const link_data: { start: number, end: number, content: string, line: number }[] = [];
    var inline_link_data: { start: number, end: number, content: string, line: number }[] = [];
    const clean_lines: string[] = [];

    const regex = /^--\s*@hover:\s*\((\d+),(\d+)\)\[(.*?)\]$/;
    const unclosed_regex = /^--\s*@hover:\s*\((\d+),(\d+)\)\[(.*)/;
    const closed_regex = /(.*)(?<!\\)]$/;

    const link_regex = /^--\s*@link:\s*\((\d+),(\d+)\)\[(.*?)\]$/;

    var unclosed = false;
    var unclosed_start = 0;
    var unclosed_end = 0;
    var unclosed_content_body = "";
    var line_number = 1;
    var inline_line_number = 1;
    for (let i = 0; i < lines.length; i++) {
        const line = lines[i];
        if (unclosed) {
            const link_match = line.match(link_regex);
            const match = line.match(closed_regex);
            if (match && !link_match) {
                unclosed = false;
                const content = unclosed_content_body + match[1];
                hover_data.push({
                    start: unclosed_start,
                    end: unclosed_end,
                    content: getCode(highlighter.codeToHast(content, {
                        lang: 'luau',
                        themes: { light: 'github-light', dark: 'github-dark' },
                        defaultColor: false,
                        transformers: [
                            {
                                name: "luau-tooltips-link",
                                line(line, line_number) {
                                    const links = inline_link_data.map((h) => (h.line === line_number) ? h : undefined);
                                    for (let i = 0; i < links.length; i++) {
                                        const link = links[i];
                                        if (link === undefined)
                                            continue;
                                        let col = 0;
                                        const new_children: ElementContent[] = [];

                                        for (let i = 0; i < line.children.length; i++) {
                                            const token = line.children[i];
                                            if (token.type !== "element") {
                                                new_children.push(token);
                                                continue;
                                            }
                                            const text = token.children.find((c) => c.type === "text");
                                            if (!text) {
                                                new_children.push(token);
                                                continue;
                                            }
                                            const text_value = text.value;
                                            const len = text_value.length;
                                            if (len === 0)
                                                continue;
                                            if (col < link.end && col + len >= link.start) {
                                                const rel_start = Math.max(0, link.start - col);
                                                const rel_end = Math.min(len, link.end - col);
                                                if (rel_start > 0) {
                                                    new_children.push({
                                                        type: 'element',
                                                        tagName: 'span',
                                                        properties: token.properties,
                                                        children: [{ type: 'text', value: text_value.slice(0, rel_start) }],
                                                    });
                                                }
                                                new_children.push({
                                                    type: 'element',
                                                    tagName: 'a',
                                                    properties: {
                                                        ...token.properties,
                                                        href: link.content,
                                                    },
                                                    children: [{ type: 'text', value: text_value.slice(rel_start, rel_end) }],
                                                });
                                                if (rel_end < len) {
                                                    new_children.push({
                                                        type: 'element',
                                                        tagName: 'span',
                                                        properties: token.properties,
                                                        children: [{ type: 'text', value: text_value.slice(rel_end) }],
                                                    });
                                                }
                                            } else {
                                                new_children.push(token);
                                            }

                                            col += len;
                                        };
                                        line.children = new_children;
                                    }
                                    return line;
                                },
                            },
                        ]
                    })),
                    line: line_number,
                });
                inline_line_number = 1;
                inline_link_data = [];
                unclosed_content_body = "";
            } else {
                if (link_match) {
                    const [, start, end, content] = link_match;
                    inline_link_data.push({
                        start: parseInt(start, 10) - 1,
                        end: parseInt(end, 10) - 1,
                        content: content,
                        line: inline_line_number,
                    });
                } else {
                    unclosed_content_body += ((line.length > 0) ? line : " ") + '\n'
                    inline_line_number += 1;
                };
            }
            continue;
        }
        const match = line.match(regex);
        if (match) {
            const [, start, end, content] = match;
            hover_data.push({
                start: parseInt(start, 10) - 1,
                end: parseInt(end, 10) - 1,
                content: getCode(highlighter.codeToHast(content, {
                    lang: 'luau',
                    themes: { light: 'github-light', dark: 'github-dark' },
                    defaultColor: false,
                })),
                line: line_number,
            });
        } else {
            const link_match = line.match(link_regex);
            if (link_match) {
                const [, start, end, content] = link_match;
                link_data.push({
                    start: parseInt(start, 10) - 1,
                    end: parseInt(end, 10) - 1,
                    content: content,
                    line: line_number,
                });
            } else {
                const unclosed_match = line.match(unclosed_regex);
                if (unclosed_match) {
                    unclosed = true;
                    const [, start, end, content] = unclosed_match;
                    unclosed_start = parseInt(start, 10) - 1;
                    unclosed_end = parseInt(end, 10) - 1;
                    unclosed_content_body = content + '\n';
                    inline_line_number += 1;
                } else {
                    clean_lines.push(lines[i]);
                    line_number += 1;
                }
            }
        }
    }

    if (unclosed)
        throw new Error("Unclosed hover comment at line " + line_number);

    if (clean_lines[clean_lines.length - 1] === '')
        clean_lines.pop();

    return { clean_code: clean_lines.join('\n'), hover_data, link_data };
}

const highlighter = await createHighlighter({
    themes: ["github-dark", "github-light"],
    langs: ["luau"],
});

export default function rehypeLuauTooltips() {
    return async (tree, file) => {
        visitParents(tree, "element", (node) => {
            if (node.tagName !== "pre")
                return;
            const head = node.children[0];
            if (!head || head.type !== "element" || head.tagName !== "code")
                return SKIP;

            const classes = head.properties.className;
            if (!Array.isArray(classes))
                return SKIP;

            const meta: string = head.data?.meta || "";
            const language = classes.find((d) => {
                return typeof d === 'string' && d.startsWith("language-");
            });
            if (!language || language !== 'language-luau')
                return SKIP;

            if (meta.search("tooltips") == -1)
                return

            const code = head.children[0]?.value || '';

            const { clean_code, hover_data, link_data } = parseHoverComments(code);

            const hast = highlighter.codeToHast(clean_code, {
                lang: "luau",
                themes: {
                    light: "github-light",
                    dark: "github-dark",
                },
                defaultColor: false,
                transformers: [
                    {
                        name: "luau-tooltips",
                        line(line, line_number) {
                            const links = link_data.map((h) => (h.line === line_number) ? h : undefined);
                            for (let i = 0; i < links.length; i++) {
                                const link = links[i];
                                if (link === undefined)
                                    continue;
                                let col = 0;
                                const new_children: ElementContent[] = [];

                                for (let i = 0; i < line.children.length; i++) {
                                    const token = line.children[i];
                                    if (token.type !== "element") {
                                        new_children.push(token);
                                        continue;
                                    }
                                    const text = token.children.find((c) => c.type === "text");
                                    if (!text) {
                                        new_children.push(token);
                                        continue;
                                    }
                                    const text_value = text.value;
                                    const len = text_value.length;
                                    if (len === 0)
                                        continue;
                                    if (col < link.end && col + len >= link.start) {
                                        const rel_start = Math.max(0, link.start - col);
                                        const rel_end = Math.min(len, link.end - col);
                                        if (rel_start > 0) {
                                            new_children.push({
                                                type: 'element',
                                                tagName: 'span',
                                                properties: token.properties,
                                                children: [{ type: 'text', value: text_value.slice(0, rel_start) }],
                                            });
                                        }
                                        new_children.push({
                                            type: 'element',
                                            tagName: 'a',
                                            properties: {
                                                ...token.properties,
                                                href: link.content,
                                            },
                                            children: [{ type: 'text', value: text_value.slice(rel_start, rel_end) }],
                                        });
                                        if (rel_end < len) {
                                            new_children.push({
                                                type: 'element',
                                                tagName: 'span',
                                                properties: token.properties,
                                                children: [{ type: 'text', value: text_value.slice(rel_end) }],
                                            });
                                        }
                                    } else {
                                        new_children.push(token);
                                    }

                                    col += len;
                                };
                                line.children = new_children;
                            }
                            const hovers = hover_data.map((h) => (h.line === line_number) ? h : undefined);
                            for (let i = 0; i < hovers.length; i++) {
                                const hover = hovers[i];
                                if (hover === undefined)
                                    continue;
                                let col = 0;
                                const new_children: ElementContent[] = [];

                                for (let i = 0; i < line.children.length; i++) {
                                    const token = line.children[i];
                                    if (token.type !== "element") {
                                        new_children.push(token);
                                        continue;
                                    }
                                    const text = token.children.find((c) => c.type === "text");
                                    if (!text) {
                                        new_children.push(token);
                                        continue;
                                    }
                                    const text_value = text.value;
                                    const len = text_value.length;
                                    if (col < hover.end && col + len >= hover.start) {
                                        const rel_start = Math.max(0, hover.start - col);
                                        const rel_end = Math.min(len, hover.end - col);
                                        if (rel_start > 0) {
                                            new_children.push({
                                                type: 'element',
                                                tagName: 'span',
                                                properties: token.properties,
                                                children: [{ type: 'text', value: text_value.slice(0, rel_start) }],
                                            });
                                        }
                                        new_children.push({
                                            type: 'element',
                                            tagName: 'span',
                                            properties: {
                                                ...token.properties,
                                                className: [...(token.properties.className as any || []), 'luau-tooltips'],
                                            },
                                            children: [{ type: 'text', value: text_value.slice(rel_start, rel_end) }, {
                                                type: 'element',
                                                tagName: 'span',
                                                properties: {
                                                    className: [
                                                        "x:bg-white", "x:dark:bg-black", "x:rounded-md",
                                                        "x:ring-1", "x:ring-inset", "x:ring-gray-300", "x:dark:ring-neutral-700",
                                                        "x:contrast-more:ring-gray-900", "x:contrast-more:dark:ring-gray-50", "x:contrast-more:contrast-150",
                                                        'luau-tooltips-content'
                                                    ],
                                                },
                                                children: hover.content?.children || [],
                                            }],
                                        });
                                        if (rel_end < len) {
                                            new_children.push({
                                                type: 'element',
                                                tagName: 'span',
                                                properties: token.properties,
                                                children: [{ type: 'text', value: text_value.slice(rel_end) }],
                                            });
                                        }
                                    } else {
                                        new_children.push(token);
                                    }

                                    col += len;
                                };
                                line.children = new_children;
                            }
                            return line;
                        },
                    },
                ],
            });

            const code_hast = getCode(hast);
            if (!code_hast)
                return;
            if (meta.search("showLineNumbers") >= 0)
                head.properties["data-line-numbers"] = true;
            node.className = [...(node.className as any || []), 'luau-code-block'];
            node.children = [
                {
                    type: "element",
                    tagName: "code",
                    properties: head.properties,
                    data: head.data,
                    position: head.position,
                    children: code_hast.children,
                },
            ];
        });

        return tree;
    };
}