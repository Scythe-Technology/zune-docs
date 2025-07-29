"use client";
import { useEffect } from "react";

export default function TooltipHover() {
    useEffect(() => {
        var handlers = new Map<Element, EventListener[]>();
        var window_handlers = new Map<string, EventListener[]>();
        var window_observers = new Array<ResizeObserver>();

        let last_clicked_tooltip: HTMLElement | null = null
        const unselectTooltip = () => {
            if (last_clicked_tooltip) {
                last_clicked_tooltip.classList.remove("luau-tooltips-content-static");
                last_clicked_tooltip = null
            }
        }
        const selectTooltip = (tooltip: HTMLElement) => {
            if (last_clicked_tooltip === tooltip)
                return;
            unselectTooltip();
            tooltip.classList.add("luau-tooltips-content-static");
            last_clicked_tooltip = tooltip;
        }

        const bind = (el: Element) => {
            if (handlers.has(el))
                return;
            const tooltip = el.querySelector(".luau-tooltips-content") as HTMLElement | null;
            if (!tooltip)
                return;

            const updatePosition = () => {
                const tooltip_rect = tooltip.getBoundingClientRect();
                const rect = el.getBoundingClientRect();
                const top = Math.max(
                    16,
                    Math.min(rect.top + rect.height + 2, window.innerHeight - tooltip_rect.height - 16)
                );
                const left = Math.max(
                    16,
                    Math.min(rect.left + 4, window.innerWidth - tooltip_rect.width - 16)
                );

                tooltip.style.top = `${top}px`;
                tooltip.style.left = `${left}px`;
            };

            const onEnter = () => {
                updatePosition();
                if (last_clicked_tooltip !== tooltip)
                    unselectTooltip();
            };

            const update = () => {
                if (!last_clicked_tooltip)
                    return;
                if (last_clicked_tooltip !== tooltip)
                    return;
                updatePosition();
            };

            window.addEventListener("scroll", update, true);
            window.addEventListener("resize", update);

            const resizeObserver = new ResizeObserver(update);
            resizeObserver.observe(el);

            {
                const list = window_handlers.get("resize") || [];
                list.push(update);
                window_handlers.set("resize", list);
            }
            {
                const list = window_handlers.get("scroll") || [];
                list.push(update);
                window_handlers.set("scroll", list);
            }

            window_observers.push(resizeObserver);

            const onClick: EventListener = (e) => {
                e.stopPropagation();
                selectTooltip(tooltip);
                updatePosition();
            }

            el.addEventListener("click", onClick)
            el.addEventListener("mouseenter", onEnter);
            handlers.set(el, [onEnter, onClick]);
        };

        document.querySelectorAll(".luau-tooltips").forEach(bind);

        const observer = new MutationObserver((mutations) => {
            mutations.forEach((m) =>
                Array.from(m.addedNodes).forEach((node) => {
                    if (!(node instanceof Element))
                        return;
                    if (node.matches(".luau-tooltips"))
                        bind(node);
                    node.querySelectorAll(".luau-tooltips").forEach(bind);
                })
            );
        });
        observer.observe(document.body, { childList: true, subtree: true });

        const globalOnClick = (e) => {
            if (
                last_clicked_tooltip &&
                !(last_clicked_tooltip.parentElement?.contains(e.target as Node))
            )
                unselectTooltip();
        }

        document.addEventListener("click", globalOnClick);

        return () => {
            document.removeEventListener("click", globalOnClick);
            observer.disconnect();
            handlers.forEach(
                (handles, el) => handles.forEach(handle => el.removeEventListener("mouseenter", handle))
            );
            handlers.clear();

            window_handlers.forEach((handles, event) => {
                handles.forEach(handle => window.removeEventListener(event, handle));
            });
            window_handlers.clear();

            window_observers.forEach(observer => observer.disconnect());
        };
    }, []);

    return null;
}