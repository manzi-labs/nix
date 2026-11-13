{ ... }:
{
  # Agentic coding TUI pointed at the local Ollama server. opencode probes
  # http://127.0.0.1:11434 and discovers installed models by itself, so no
  # provider block is needed. Colours come from Stylix's opencode target.
  programs.opencode = {
    enable = true;

    settings = {
      model = "ollama/gpt-oss:20b";
    };
  };
}
