{
  description = "A Nix-flake-based SALEOR devops environment ";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };
  outputs =
    { self
    , nixpkgs
    }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      forEachSupportedSystem = f:
        nixpkgs.lib.genAttrs supportedSystems (system:
          f {
            pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };
          });
    in
    {
      devShells = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            crane
            kubecolor
            kubectl
            kustomize
            kubernetes-helm
            k9s
            openssl
            talosctl
            cmctl
            terraform
            nodejs
          ];
          shellHook = ''
            echo
            echo -e "\e[1;32m Talos - kubernetes (talos)\e[0m"
            echo
            echo " * ${pkgs.kubectl.name} / ${pkgs.kubecolor.name}"
            echo " * ${pkgs.kubernetes-helm.name}"
            echo " * ${pkgs.k9s.name}"
            echo " * ${pkgs.terraform.name}"
            echo " * ${pkgs.openssl.name}"
            echo " * ${pkgs.talosctl.name}"
            echo

            export WA_HOME='/wa/infra/k8s/a3c-lab-3'
            export CP_IP="cp0.k8s3.lab.atricore.io"
            export WK0_IP="wk0.k8s3.lab.atricore.io"
            export WK1_IP="wk1.k8s3.lab.atricore.io"
            export KUBECONFIG="$WA_HOME/kubeconfig"
            export KUBE_CONFIG_PATH="$KUBECONFIG"
            export TALOSCONFIG="$WA_HOME/_out/talosconfig"

            # Add bash autocomplete for kubernetes
            alias k="kubecolor"
            alias tp='terraform plan -var-file=./envs/talos.tfvars'
            alias ta='terraform apply -var-file=./envs/talos.tfvars'
            alias tpf='terraform plan -target=module.saleor_platform -var-file=./envs/talos.tfvars'
            alias taf='terraform apply -target=module.saleor_platform -var-file=./envs/talos.tfvars'
            alias tps='terraform plan -target=module.saleor_storefront -var-file=./envs/talos.tfvars'
            alias tas='terraform apply -target=module.saleor_storefront -var-file=./envs/talos.tfvars'
            source <(${pkgs.kubectl}/bin/kubectl completion bash)
            complete -o default -F __start_kubectl k

            echo
            echo " - WA_HOME=$WA_HOME"
            echo " - CP_IP=$CP_IP"
            echo " - WK0_IP=$WK0_IP"
            echo " - WK1_IP=$WK1_IP"
            echo " - WK2_IP=$WK2_IP"
            echo
            echo " - KUBEC_CONFIG_PATH=$KUBE_CONFIG_PATH"
            echo
            k version
            echo
            echo "NOTE: use k alias to run kubecolor.  Autocomplete is also enabled."
            echo
            echo "*** Remember to add an IP route for the loadbalancer assigned ips via the cluster node ip"
            echo -e "\e[1;32msudo ip route add 10.230.0.0/24 via 10.0.3.40\e[0m"
          '';
        };
      });
    };
}
