{ lib, stdenv, fetchFromGitHub, zlib, protobuf, ncurses, pkg-config
, makeWrapper, perl, openssl, autoreconfHook, openssh, bash-completion
, withUtempter ? stdenv.isLinux && !stdenv.hostPlatform.isMusl, libutempter }:

stdenv.mkDerivation rec {
  pname = "mosh";
  version = "1.4.0";

  src = ./..;

  nativeBuildInputs = [ autoreconfHook pkg-config makeWrapper protobuf perl ];
  buildInputs = [ protobuf ncurses zlib openssl bash-completion perl ]
    ++ lib.optional withUtempter libutempter;

  strictDeps = true;

  enableParallelBuilding = true;

  patches = [
    ./ssh_path.patch
    ./mosh-client_path.patch
    # Fix build with bash-completion 2.10
    ./bash_completion_datadir.patch
  ];

  postPatch = ''
    substituteInPlace scripts/mosh.pl \
      --subst-var-by ssh "${openssh}/bin/ssh" \
      --subst-var-by mosh-client "$out/bin/mosh-client"
  '';

  configureFlags = [ "--enable-completion" ]
    ++ lib.optional withUtempter "--with-utempter";

  postInstall = ''
      wrapProgram $out/bin/mosh --prefix PERL5LIB : $PERL5LIB
  '';
}
