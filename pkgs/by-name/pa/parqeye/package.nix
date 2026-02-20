{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "parqeye";
  version = "0.0.2";

  src = fetchFromGitHub {
    owner = "kaushiksrini";
    repo = "parqeye";
    tag = "v${finalAttrs.version}";
    hash = "sha256-gsH/dSxQRbfTdWeZ8KCTxjQmmD8yfAxrr+WAs/nGtUw=";
  };

  cargoHash = "sha256-Xk1T+1TDMs13y/1ghieiewy2ZwrHZD0U6iZw3n/DMKI=";

  # Upstream tests expect the parquet-testing submodule, which is not shipped
  # in the GitHub release archive used for packaging.
  doCheck = false;

  meta = {
    description = "Peek inside Parquet files right from your terminal";
    homepage = "https://github.com/kaushiksrini/parqeye";
    changelog = "https://github.com/kaushiksrini/parqeye/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "parqeye";
    platforms = lib.platforms.unix;
  };
})
