{ pkgs, ... }:
{
  services.ollama = {
    enable = true;

    # ollama-cuda is in no binary cache, so it compiles here. nixpkgs would
    # build kernels for nine CUDA architectures by default; the 5070 Ti is
    # Blackwell / compute 12.0, so build sm_120 alone.
    package = pkgs.ollama-cuda.override { cudaArches = [ "sm_120" ]; };

    # Pulled by ollama-model-loader.service once the server is up.
    loadModels = [
      "gpt-oss:20b" # 14GB - strongest coding model that still fits 16GB

      # Uncensored. Heretic-method abliteration of Qwen3.5-9B, pulled straight
      # from HuggingFace. Q8_0 is near-lossless and still leaves ~2.5GB of
      # VRAM spare, which a 27B only manages at a lossy 3-bit quant.
      "hf.co/DavidAU/Qwen3.5-9B-The-Defiant-Fable-Uncensored-Heretic-NEO-IMATRIX-MAX-MTP-GGUF:Q8_0"
    ];

    environmentVariables = {
      OLLAMA_FLASH_ATTENTION = "1";
      # Halves the KV cache footprint, which is what buys the headroom for a
      # 14GB model on a 16GB card shared with Plasma.
      OLLAMA_KV_CACHE_TYPE = "q8_0";

      # Ollama's VRAM-based default lands on 4096, which is too short for
      # agentic work. Measured on this card with the q8_0 cache above: both
      # models stay at 100% GPU at 32k (gpt-oss 13.8GB, qwen 12.8GB of
      # 15.4GB), leaving headroom for the desktop. gpt-oss alone also holds
      # 100% GPU at 64k, but that only leaves ~1GB spare.
      OLLAMA_CONTEXT_LENGTH = "32768";
    };
  };

  # Browser chat UI on http://localhost:8080. Binds to 127.0.0.1 by default.
  services.open-webui = {
    enable = true;
    port = 8080;

    environment = {
      OLLAMA_API_BASE_URL = "http://127.0.0.1:11434";
      WEBUI_AUTH = "False"; # single local user, no login screen
      ANONYMIZED_TELEMETRY = "False";
      DO_NOT_TRACK = "True";
      SCARF_NO_ANALYTICS = "True";
    };
  };

  environment.systemPackages = [ pkgs.nvtopPackages.nvidia ];
}
