# Run ‘nixos-help’ to get help.

{ config, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # <home-manager/nixos>
    ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Filesystems
  boot.supportedFilesystems = [ "ntfs" ];

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Network proxy
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Time
  time.timeZone = "Asia/Hong_Kong";

  # I18n
  i18n.defaultLocale = "en_HK.UTF-8";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    # jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    # media-session.enable = true;
  };

  # Define user account. Don't forget to set a password with ‘passwd’.
  users.users.sam = {
    isNormalUser = true;
    description = "Sam";
    extraGroups = [
      "networkmanager"
      # Enable sudo
      "wheel"
    ];
    initialPassword = "password";
    packages = with pkgs; [
      wget
      git
      croc
      vscode
      zoxide
      firefox-devedition
      curl 
      zsh
      starship
      kitty
      rustup
      gh
      supabase-cli
      fd
      fzf
      ripgrep
      less
      tree
      bat 
      ranger
      brave
      nextcloud-client
      cloudflared
      tailscale
      toybox  # Lightweight implementation of some Unix command line utils
      bottom
      openrgb
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Install packages
  environment.systemPackages = with pkgs; [
    neovim

    # CUDA
    # https://github.com/grahamc/nixos-cuda-example/blob/master/configuration.nix
    cmake
    gnumake
    gcc
    pciutils
    file
    cudatoolkit
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # OpenSSH daemon
  services.openssh.enable = true;

  # Firewall
  # networking.firewall.allowedTCPPorts = [ 80 443 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Lets Encrypt
  security.acme = {
    acceptTerms = true;
    defaults.email = "mingsum.sam@gmail.com";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  # Nix experimental features
  nix = {
    package = pkgs.nixFlakes;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  # OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # X11
  services.xserver = {
    enable = true;
    videoDrivers = ["nvidia"];
    libinput.enable = true;
    layout = "us";
    xkbVariant = "";
    autoRepeatDelay = 120;  # Overriden by GNOME
    autoRepeatInterval = 30;  # Overriden by GNOME
    # Cinnamon
    displayManager.lightdm.enable = true;
    desktopManager.cinnamon.enable = true;
  };

  # NVidia
  hardware.nvidia = {
    modesetting.enable = true;
    # Use propritary version of the kernel module
    open = false;
    # Enable NVidia settings menu
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;  
  };
  systemd.services.nvidia-control-devices = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.ExecStart = "${pkgs.linuxPackages.nvidia_x11.bin}/bin/nvidia-smi";
  };

  # NextCloud
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/web-apps/nextcloud.md
  # https://nixos.org/manual/nixos/stable/index.html#module-services-nextcloud-basic-usage
  # https://nixos.wiki/wiki/Nextcloud
  services.nextcloud = {
    enable = true;
    hostName = "cloud.artizon.io";
    config = {
      # overwriteProtocol = "https";
      extraTrustedDomains = [
        "cloud.artizon.io"  # Cloudflare tunnel
        "100.98.28.84"  # Tailscale
	"localhost"
      ];
      dbtype = "sqlite";
      adminpassFile = "/etc/nixos/secrets/nextcloud-sqlite";
      adminuser = "root";
    };
    https = false;  # Cloudflare provides SSL cert already and Tailscale is E2E encrypted
    configureRedis = true;  # Caching
  };

  # Nginx (reverse proxy for e.g. NextCloud)
  services.nginx = {
    enable = true;
    virtualHosts.${config.services.nextcloud.hostName} = {
      forceSSL = false;
      enableACME = false;
      serverAliases = config.services.nextcloud.config.extraTrustedDomains;
      # locations."/" = {
      #   root = "/var/www";
      # };
    };
  };

  # Tailscale
  services.tailscale.enable = true;
}
