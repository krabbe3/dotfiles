transcribe-notes() {
    if [[ $# -ne 2 ]]; then
        echo "Usage: transcribe-notes <src_file_or_dir> <dest_dir>" >&2
        return 1
    fi

    local current_dir="${${(%):-%x}:A:h}"
    local script_path="$current_dir/supernote_pipeline.py"
    local env_name="transcriber"

    local src="$1"
    local dst="$2"

    if [[ ! -f "$script_path" ]]; then
        echo "Error: Pipeline script not found at: $script_path" >&2
        return 1
    fi

    conda run -n "$env_name" --no-capture-output python "$script_path" "$src" "$dst"
}
compdef '_files' transcribe-notes
