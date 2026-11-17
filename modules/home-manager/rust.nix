{ pkgs, ... }:
{
  home.packages = with pkgs; [
    cargo
    rustc
    clippy
    rustfmt
    rust-analyzer
    gcc # rustc uses cc as the linker
  ];

  # rust-analyzer needs the std sources to complete and jump into std
  home.sessionVariables.RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";

  programs.neovim.initLua = ''
    vim.lsp.config("rust_analyzer", {
      cmd = { "rust-analyzer" },
      filetypes = { "rust" },
      root_markers = { "Cargo.toml", ".git" },
    })
    vim.lsp.enable("rust_analyzer")
  '';
}
