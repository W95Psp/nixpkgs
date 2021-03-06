{ stdenv
, fetchFromGitHub
, pkg-config
, installShellFiles
, buildGoPackage
, gpgme
, lvm2
, btrfs-progs
, libseccomp
, systemd
, go-md2man
, nixosTests
}:

buildGoPackage rec {
  pname = "podman";
  version = "1.9.1";

  src = fetchFromGitHub {
    owner = "containers";
    repo = "libpod";
    rev = "v${version}";
    sha256 = "0dr5vd52fnjwx3zn2nj2nlvkbvh5bg579nf3qw8swrn8i1jwxd6j";
  };

  goPackagePath = "github.com/containers/libpod";

  outputs = [ "out" "man" ];

  nativeBuildInputs = [ pkg-config go-md2man installShellFiles ];

  buildInputs = stdenv.lib.optionals stdenv.isLinux [ btrfs-progs libseccomp gpgme lvm2 systemd ];

  buildPhase = ''
    pushd go/src/${goPackagePath}
    patchShebangs .
    ${if stdenv.isDarwin
      then "make CGO_ENABLED=0 BUILDTAGS='remoteclient containers_image_openpgp exclude_graphdriver_devicemapper' varlink_generate all"
      else "make binaries docs"}
  '';

  installPhase = ''
    install -Dm555 bin/podman $out/bin/podman
    installShellCompletion --bash completions/bash/podman
    installShellCompletion --zsh completions/zsh/_podman
    MANDIR=$man/share/man make install.man
  '';

  passthru.tests.podman = nixosTests.podman;

  meta = with stdenv.lib; {
    homepage = "https://podman.io/";
    description = "A program for managing pods, containers and container images";
    license = licenses.asl20;
    maintainers = with maintainers; [ marsam ] ++ teams.podman.members;
    platforms = platforms.unix;
  };
}
