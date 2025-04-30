local M = {}

function M:peek(job)
    -- File
    -- https://yazi-rs.github.io/docs/plugins/types/#shared.file

    -- Command
    -- https://yazi-rs.github.io/docs/plugins/utils#command

    -- Check if file exists
    if not job.file then
        return
    end

    local tmp_file = os.tmpname()

    local status, err = Command("heic-convert")
        :args({
            tostring(job.file.url),
            tmp_file,
        })
        :stdout(Command.PIPED)
        :stderr(Command.PIPED)
        :status()

    if status ~= nil then
        ya.err(err)
        return
    end

    -- TODO
end

function M:seek(job)
    -- TODO
end

return M
