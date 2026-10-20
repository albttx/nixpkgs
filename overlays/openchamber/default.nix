final: super:
let
  pkgs = super.pkgs;
  nodejs = pkgs.nodejs;
in
{
  # Published npm CLI (@openchamber/web). Install scripts are skipped so
  # node-gyp is not required; prebuilt node-pty and sherpa-onnx binaries
  # still ship. https://www.npmjs.com/package/@openchamber/web
  openchamber = pkgs.buildNpmPackage {
    pname = "openchamber";
    version = "1.24.2";

    src = pkgs.lib.sources.sourceByRegex ./. [
      "^package\\.json$"
      "^package-lock\\.json$"
    ];

    npmDepsHash = "sha256-m7ZDooVQz9r+pENXY6jPuDdu+y/g9Ew7fqbsOBKS/J4=";

    npmFlags = [ "--ignore-scripts" ];
    dontNpmBuild = true;
    makeCacheWritable = true;

    nativeBuildInputs = [ pkgs.makeWrapper ];

    postInstall = ''
      rm -f "$out/bin/"*
      makeWrapper ${nodejs}/bin/node "$out/bin/openchamber" \
        --add-flags "$out/lib/node_modules/openchamber/node_modules/@openchamber/web/bin/cli.js"
    '';

    meta = with pkgs.lib; {
      description = "Web interface and daemon CLI for the OpenCode AI agent";
      homepage = "https://github.com/openchamber/openchamber";
      license = licenses.mit;
      mainProgram = "openchamber";
    };
  };
}
