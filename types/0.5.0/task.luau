--- @name Task
--- @global `zune.task`
--- @summary A library to interact with the task scheduler.

type __0__ = typeof(nil);

type TaskLib = {
    --- Cancels a task, and resets thread.
    --- @param thread The thread to cancel.
    cancel: (thread: thread) -> (),
    --- Runs function or thread on end of scheduler frame.
    --- @param f The function to defer.
    --- @param A... The arguments to pass to the function.
    defer: <A..., R...>(f: ((A...) -> R...) | thread, A...) -> thread,
    --- Runs function or thread after a certain amount of time.
    --- @param sec The amount of time to delay.
    --- @param f The function to run after the delay.
    --- @param A... The arguments to pass to the function.
    delay: <A..., R...>(sec: number, f: ((A...) -> (R...)) | thread, A...) -> thread,
    --- Runs function or thread immediately.
    --- @param f The function to run immediately.
    --- @param A... The arguments to pass to the function.
    spawn: <A..., R...>(f: ((A...) -> (R...)) | thread, A...) -> thread,
    --- Yields and resumes current calling thread after a certain amount of time, returning the total time the sleep took.
    --- @param sec The amount of time to sleep.
    --- @return The total time waited.
    wait: (sec: number?) -> number,
    --- Counts the number of current tasks.
    ---
    --- Optional kinds parameter to count a specific kind of task.
    ---
    --- Kinds:
    --- - `s` to count sleeping tasks.
    --- - `d` to count deferred tasks.
    --- - `w` to count awaiting tasks. (zune backend)
    --- - `t` to count internal tasks. (zune backend)
    --- @param kinds The kinds of tasks to count. `nil` to count all kinds.
    --- @default_param kinds nil
    --- @throws Error
    count: (() -> number) & ((kinds: string) -> ...number),
}

return {} :: TaskLib;
